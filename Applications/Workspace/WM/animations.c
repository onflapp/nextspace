/*
 *  Workspace window manager
 *  Copyright (c) 2015-2021 Sergii Stoian
 *
 *  Window Maker window manager
 *  Copyright (c) 1997-2003 Alfredo K. Kojima
 *  Copyright (c) 1998-2003 Dan Pascu
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#include "WM.h"

#include <X11/Xlib.h>
#include <X11/Xutil.h>

#include <stdlib.h>
#include <unistd.h>
#include <math.h>
#include <time.h>

#include <wraster.h>

#include <core/util.h>
#include <core/log_utils.h>

#include <core/wevent.h>

#include "WM.h"
#include "screen.h"
#include "framewin.h"
#include "window.h"
#include "actions.h"
#include "xrandr.h"
#include "stacking.h"
#include "defaults.h"

#include "animations.h"

#define NORMAL_ICON_KABOOM

#define PIECES ((64/ICON_KABOOM_PIECE_SIZE)*(64/ICON_KABOOM_PIECE_SIZE))
#define KAB_PRECISION		4
/* size of the pieces in the undocked icon explosion */
#define ICON_KABOOM_PIECE_SIZE	4
#define BOUNCE_HZ		25
#define BOUNCE_DELAY		(1000/BOUNCE_HZ)
#define BOUNCE_HEIGHT		24
#define BOUNCE_LENGTH		0.3
#define BOUNCE_DAMP		0.6
#define URGENT_BOUNCE_DELAY	3000

#ifndef HAVE_FLOAT_MATHFUNC
#  define sinf(x) ((float)sin((double)(x)))
#  define cosf(x) ((float)cos((double)(x)))
#  define sqrtf(x) ((float)sqrt((double)(x)))
#  define atan2f(y, x) ((float)atan((double)(y) / (double)(x)))
#endif /* HAVE_FLOAT_MATHFUNC */

/* Zoom animation */
#define MINIATURIZE_ANIMATION_FRAMES_Z   7
#define MINIATURIZE_ANIMATION_STEPS_Z    16
#define MINIATURIZE_ANIMATION_DELAY_Z    10000

/* Twist animation */
#define MINIATURIZE_ANIMATION_FRAMES_T   12
#define MINIATURIZE_ANIMATION_STEPS_T    16
#define MINIATURIZE_ANIMATION_DELAY_T    20000
#define MINIATURIZE_ANIMATION_TWIST_T    0.5

/* Flip animation */
#define MINIATURIZE_ANIMATION_FRAMES_F   12
#define MINIATURIZE_ANIMATION_STEPS_F    16
#define MINIATURIZE_ANIMATION_DELAY_F    20000
#define MINIATURIZE_ANIMATION_TWIST_F    0.5

/* shade animation */
#define SHADE_STEPS_UF		5
#define SHADE_DELAY_UF		0

#define SHADE_STEPS_F		10
#define SHADE_DELAY_F		0

#define SHADE_STEPS_M		15
#define SHADE_DELAY_M		0

#define SHADE_STEPS_S		30
#define SHADE_DELAY_S		0

#define SHADE_STEPS_US		40
#define SHADE_DELAY_US		10

#ifdef USE_ANIMATIONS
static struct {
  int steps;
  int delay;
} shadePars[5] = {
  { SHADE_STEPS_UF, SHADE_DELAY_UF },
  { SHADE_STEPS_F, SHADE_DELAY_F },
  { SHADE_STEPS_M, SHADE_DELAY_M },
  { SHADE_STEPS_S, SHADE_DELAY_S },
  { SHADE_STEPS_US, SHADE_DELAY_US }
};

#define SHADE_STEPS	shadePars[(int)wPreferences.shade_speed].steps
#define SHADE_DELAY	shadePars[(int)wPreferences.shade_speed].delay
#endif

void DoKaboom(WScreen *scr, Window win, int x, int y)
{
#ifdef NORMAL_ICON_KABOOM
  int i, j, k;
  int sw = scr->width, sh = scr->height;
  int px[PIECES];
  short py[PIECES];
  char pvx[PIECES], pvy[PIECES];
  /* in MkLinux/PPC gcc seems to think that char is unsigned? */
  signed char ax[PIECES], ay[PIECES];
  Pixmap tmp;

  XSetClipMask(dpy, scr->copy_gc, None);
  tmp = XCreatePixmap(dpy, scr->root_win, wPreferences.icon_size, wPreferences.icon_size, scr->depth);
  if (scr->w_visual == DefaultVisual(dpy, scr->screen))
    XCopyArea(dpy, win, tmp, scr->copy_gc, 0, 0, wPreferences.icon_size, wPreferences.icon_size, 0, 0);
  else {
    XImage *image;

    image = XGetImage(dpy, win, 0, 0, wPreferences.icon_size,
                      wPreferences.icon_size, AllPlanes, ZPixmap);
    if (!image) {
      XUnmapWindow(dpy, win);
      return;
    }
    XPutImage(dpy, tmp, scr->copy_gc, image, 0, 0, 0, 0,
              wPreferences.icon_size, wPreferences.icon_size);
    XDestroyImage(image);
  }

  for (i = 0, k = 0; i < wPreferences.icon_size / ICON_KABOOM_PIECE_SIZE && k < PIECES; i++) {
    for (j = 0; j < wPreferences.icon_size / ICON_KABOOM_PIECE_SIZE && k < PIECES; j++) {
      if (rand() % 2) {
        ax[k] = i;
        ay[k] = j;
        px[k] = (x + i * ICON_KABOOM_PIECE_SIZE) << KAB_PRECISION;
        py[k] = y + j * ICON_KABOOM_PIECE_SIZE;
        pvx[k] = rand() % (1 << (KAB_PRECISION + 3)) - (1 << (KAB_PRECISION + 3)) / 2;
        pvy[k] = -15 - rand() % 7;
        k++;
      } else {
        ax[k] = -1;
      }
    }
  }

  XUnmapWindow(dpy, win);

  j = k;
  while (k > 0) {
    XEvent foo;

    if (XCheckTypedEvent(dpy, ButtonPress, &foo)) {
      XPutBackEvent(dpy, &foo);
      XClearWindow(dpy, scr->root_win);
      break;
    }

    for (i = 0; i < j; i++) {
      if (ax[i] >= 0) {
        int _px = px[i] >> KAB_PRECISION;
        XClearArea(dpy, scr->root_win, _px, py[i],
                   ICON_KABOOM_PIECE_SIZE, ICON_KABOOM_PIECE_SIZE, False);
        px[i] += pvx[i];
        py[i] += pvy[i];
        _px = px[i] >> KAB_PRECISION;
        pvy[i]++;
        if (_px < -wPreferences.icon_size || _px > sw || py[i] >= sh) {
          ax[i] = -1;
          k--;
        } else {
          XCopyArea(dpy, tmp, scr->root_win, scr->copy_gc,
                    ax[i] * ICON_KABOOM_PIECE_SIZE, ay[i] * ICON_KABOOM_PIECE_SIZE,
                    ICON_KABOOM_PIECE_SIZE, ICON_KABOOM_PIECE_SIZE, _px, py[i]);
        }
      }
    }

    XFlush(dpy);
    wusleep(MINIATURIZE_ANIMATION_DELAY_Z * 2);
  }

  XFreePixmap(dpy, tmp);
#endif	/* NORMAL_ICON_KABOOM */
}

Pixmap MakeGhostIcon(WScreen * scr, Drawable drawable)
{
  RImage *back;
  RColor color;
  Pixmap pixmap;

  if (!drawable)
    return None;

  back = RCreateImageFromDrawable(scr->rcontext, drawable, None);
  if (!back)
    return None;

  color.red = 0xff;
  color.green = 0xff;
  color.blue = 0xff;
  color.alpha = 100;

  RClearImage(back, &color);
  RConvertImage(scr->rcontext, back, &pixmap);

  RReleaseImage(back);

  return pixmap;
}

void DoWindowBirth(WWindow *wwin)
{
#ifdef WINDOW_BIRTH_ZOOM
  int center_x, center_y;
  int width = wwin->frame->core->width;
  int height = wwin->frame->core->height;
  int w = WMIN(width, 20);
  int h = WMIN(height, 20);
  WScreen *scr = wwin->screen_ptr;

  center_x = wwin->frame_x + (width - w) / 2;
  center_y = wwin->frame_y + (height - h) / 2;

  animateResize(scr, center_x, center_y, 1, 1, wwin->frame_x, wwin->frame_y, width, height);
#else
  /* Parameter not used, but tell the compiler that it is ok */
  (void) wwin;
#endif
}

typedef struct AppBouncerData {
  WApplication *wapp;
  int count;
  int pow;
  int dir;
  CFRunLoopTimerRef timer;
} AppBouncerData;

static void doAppBounce(CFRunLoopTimerRef timer, void *arg)
{
  AppBouncerData *data = (AppBouncerData*)arg;
  WAppIcon *aicon = data->wapp->app_icon;

  if (!aicon)
    return;

 reinit:
  if (data->wapp->refcount > 1) {
    if (wPreferences.raise_appicons_when_bouncing)
      XRaiseWindow(dpy, aicon->icon->core->window);

    const double ticks = BOUNCE_HZ * BOUNCE_LENGTH;
    const double s = sqrt(BOUNCE_HEIGHT)/(ticks/2);
    double h = BOUNCE_HEIGHT*pow(BOUNCE_DAMP, data->pow);
    double sqrt_h = sqrt(h);
    if (h > 3) {
      double offset, x = s * data->count - sqrt_h;
      if (x > sqrt_h) {
        ++data->pow;
        data->count = 0;
        goto reinit;
      } else ++data->count;
      offset = h - x*x;

      switch (data->dir) {
      case 0: /* left, bounce to right */
        XMoveWindow(dpy, aicon->icon->core->window,
                    aicon->x_pos + (int)offset, aicon->y_pos);
        break;
      case 1: /* right, bounce to left */
        XMoveWindow(dpy, aicon->icon->core->window,
                    aicon->x_pos - (int)offset, aicon->y_pos);
        break;
      case 2: /* top, bounce down */
        XMoveWindow(dpy, aicon->icon->core->window,
                    aicon->x_pos, aicon->y_pos + (int)offset);
        break;
      case 3: /* bottom, bounce up */
        XMoveWindow(dpy, aicon->icon->core->window,
                    aicon->x_pos, aicon->y_pos - (int)offset);
        break;
      }
      return;
    }
  }

  XMoveWindow(dpy, aicon->icon->core->window,
              aicon->x_pos, aicon->y_pos);
  CommitStackingForWindow(aicon->icon->core);
  data->wapp->flags.bouncing = 0;
  WMDeleteTimerHandler(data->timer);
  wApplicationDestroy(data->wapp);
  free(data);
}

static int bounceDirection(WAppIcon *aicon)
{
  enum { left_e = 1, right_e = 2, top_e = 4, bottom_e = 8 };

  WScreen *scr = aicon->icon->core->screen_ptr;
  WMRect rr, sr;
  int l, r, t, b, h, v;
  int dir = 0;

  rr.pos.x = aicon->x_pos;
  rr.pos.y = aicon->y_pos;
  rr.size.width = rr.size.height = 64;

  sr = wGetRectForHead(scr, wGetHeadForRect(scr, rr));

  l = rr.pos.x - sr.pos.x;
  r = sr.pos.x + sr.size.width - rr.pos.x - rr.size.width;
  t = rr.pos.y - sr.pos.y;
  b = sr.pos.y + sr.size.height - rr.pos.y - rr.size.height;

  if (l < r) {
    dir |= left_e;
    h = l;
  } else {
    dir |= right_e;
    h = r;
  }

  if (t < b) {
    dir |= top_e;
    v = t;
  } else {
    dir |= bottom_e;
    v = b;
  }

  if (aicon->dock && abs(aicon->xindex) != abs(aicon->yindex)) {
    if (abs(aicon->xindex) < abs(aicon->yindex)) dir &= ~(top_e | bottom_e);
    else dir &= ~(left_e | right_e);
  } else {
    if (h < v) dir &= ~(top_e | bottom_e);
    else dir &= ~(left_e | right_e);
  }

  switch (dir) {
  case left_e:
    dir = 0;
    break;

  case right_e:
    dir = 1;
    break;

  case top_e:
    dir = 2;
    break;

  case bottom_e:
    dir = 3;
    break;

  default:
    WMLogWarning(_("Impossible direction: %d"), dir);
    dir = 3;
    break;
  }

  return dir;
}

void wAppBounce(WApplication *wapp)
{
  if (!wPreferences.no_animations && wapp->app_icon && !wapp->flags.bouncing
      && !wPreferences.do_not_make_appicons_bounce) {
    ++wapp->refcount;
    wapp->flags.bouncing = 1;

    AppBouncerData *data = (AppBouncerData *)malloc(sizeof(AppBouncerData));
    data->wapp = wapp;
    data->count = data->pow = 0;
    data->dir = bounceDirection(wapp->app_icon);
    data->timer = WMAddTimerHandler(BOUNCE_DELAY, BOUNCE_DELAY, doAppBounce, data);
  }
}

static int appIsUrgent(WApplication *wapp)
{
  WScreen *scr;
  WWindow *wlist;

  if (!wapp->main_wwin) {
    WMLogWarning("group leader not found for window group");
    return 0;
  }
  scr = wapp->main_wwin->screen;
  wlist = scr->focused_window;
  if (!wlist)
    return 0;

  while (wlist) {
    if (wlist->main_window == wapp->main_window) {
      if (wlist->flags.urgent)
        return 1;
    }
    wlist = wlist->prev;
  }

  return 0;
}

static void doAppUrgentBounce(CFRunLoopTimerRef timer, void *arg)
{
  WApplication *wapp = (WApplication *)arg;

  if (appIsUrgent(wapp)) {
    if(wPreferences.bounce_appicons_when_urgent) wAppBounce(wapp);
  } else {
    WMDeleteTimerHandler(wapp->urgent_bounce_timer);
    wapp->urgent_bounce_timer = NULL;
  }
}

void wAppBounceWhileUrgent(WApplication *wapp)
{
  if (!wapp) return;
  if (appIsUrgent(wapp)) {
    if (!wapp->urgent_bounce_timer) {
      wapp->urgent_bounce_timer = WMAddTimerHandler(URGENT_BOUNCE_DELAY,
                                                    URGENT_BOUNCE_DELAY,
                                                    doAppUrgentBounce, wapp);
      doAppUrgentBounce(NULL, wapp);
    }
  } else {
    if (wapp->urgent_bounce_timer) {
      WMDeleteTimerHandler(wapp->urgent_bounce_timer);
      wapp->urgent_bounce_timer = NULL;
    }
  }
}

static inline void _flushExpose(void)
{
  XEvent tmpev;
  
  while (XCheckTypedEvent(dpy, Expose, &tmpev))
    WMHandleEvent(&tmpev);
}

void wShakeWindow(WWindow *wwin)
{
  int i = 0, j = 0, num_steps, num_shakes;
  int x = wwin->frame_x;
  int xo = x;
  int y = wwin->frame_y;
  int sleep_time = 2000;
  
  num_steps = 3;
  num_shakes = 3;
  for (i = 0; i < num_shakes; i++) {
    for (j = 0; j < num_steps; j++) {
      x += 10;
      XMoveWindow(dpy, wwin->frame->core->window, x, y);
      XSync(dpy, False);
      usleep(sleep_time);
    }
    for (j = 0; j < num_steps*2; j++) {
      x -= 10;
      XMoveWindow(dpy, wwin->frame->core->window, x, y);
      XSync(dpy, False);
      usleep(sleep_time);
    }
    for (j = 0; j < num_steps; j++) {
      x += 10;
      XMoveWindow(dpy, wwin->frame->core->window, x, y);
      XSync(dpy, False);
      usleep(sleep_time);
    }
    _flushExpose();
    XSync(dpy, True);
  }
  XMoveWindow(dpy, wwin->frame->core->window, xo, y);
  XFlush(dpy);
}

/*******************************************************************************/

#ifdef USE_ANIMATIONS

static void animateResizeFlip(WScreen *scr, int x, int y, int w, int h,
                              int fx, int fy, int fw, int fh, int steps)
{
#define FRAMES (MINIATURIZE_ANIMATION_FRAMES_F)
  float cx, cy, cw, ch;
  float xstep, ystep, wstep, hstep;
  XPoint points[5];
  float dx, dch, midy;
  float angle, final_angle, delta;

  xstep = (float)(fx - x) / steps;
  ystep = (float)(fy - y) / steps;
  wstep = (float)(fw - w) / steps;
  hstep = (float)(fh - h) / steps;

  cx = (float)x;
  cy = (float)y;
  cw = (float)w;
  ch = (float)h;

  final_angle = 2 * WM_PI * MINIATURIZE_ANIMATION_TWIST_F;
  delta = (float)(final_angle / FRAMES);
  for (angle = 0;; angle += delta) {
    if (angle > final_angle)
      angle = final_angle;

    dx = (cw / 10) - ((cw / 5) * sinf(angle));
    dch = (ch / 2) * cosf(angle);
    midy = cy + (ch / 2);

    points[0].x = cx + dx;
    points[0].y = midy - dch;
    points[1].x = cx + cw - dx;
    points[1].y = points[0].y;
    points[2].x = cx + cw + dx;
    points[2].y = midy + dch;
    points[3].x = cx - dx;
    points[3].y = points[2].y;
    points[4].x = points[0].x;
    points[4].y = points[0].y;

    XGrabServer(dpy);
    XDrawLines(dpy, scr->root_win, scr->frame_gc, points, 5, CoordModeOrigin);
    XFlush(dpy);
    wusleep(MINIATURIZE_ANIMATION_DELAY_F);

    XDrawLines(dpy, scr->root_win, scr->frame_gc, points, 5, CoordModeOrigin);
    XUngrabServer(dpy);
    cx += xstep;
    cy += ystep;
    cw += wstep;
    ch += hstep;
    if (angle >= final_angle)
      break;

  }
  XFlush(dpy);
#undef FRAMES
}

static void animateResizeTwist(WScreen *scr, int x, int y, int w, int h,
                               int fx, int fy, int fw, int fh, int steps)
{
#define FRAMES (MINIATURIZE_ANIMATION_FRAMES_T)
  float cx, cy, cw, ch;
  float xstep, ystep, wstep, hstep;
  XPoint points[5];
  float angle, final_angle, a, d, delta;

  x += w / 2;
  y += h / 2;
  fx += fw / 2;
  fy += fh / 2;

  xstep = (float)(fx - x) / steps;
  ystep = (float)(fy - y) / steps;
  wstep = (float)(fw - w) / steps;
  hstep = (float)(fh - h) / steps;

  cx = (float)x;
  cy = (float)y;
  cw = (float)w;
  ch = (float)h;

  final_angle = 2 * WM_PI * MINIATURIZE_ANIMATION_TWIST_T;
  delta = (float)(final_angle / FRAMES);
  for (angle = 0;; angle += delta) {
    if (angle > final_angle)
      angle = final_angle;

    a = atan2f(ch, cw);
    d = sqrtf((cw / 2) * (cw / 2) + (ch / 2) * (ch / 2));

    points[0].x = cx + cosf(angle - a) * d;
    points[0].y = cy + sinf(angle - a) * d;
    points[1].x = cx + cosf(angle + a) * d;
    points[1].y = cy + sinf(angle + a) * d;
    points[2].x = cx + cosf(angle - a + (float)WM_PI) * d;
    points[2].y = cy + sinf(angle - a + (float)WM_PI) * d;
    points[3].x = cx + cosf(angle + a + (float)WM_PI) * d;
    points[3].y = cy + sinf(angle + a + (float)WM_PI) * d;
    points[4].x = cx + cosf(angle - a) * d;
    points[4].y = cy + sinf(angle - a) * d;
    XGrabServer(dpy);
    XDrawLines(dpy, scr->root_win, scr->frame_gc, points, 5, CoordModeOrigin);
    XFlush(dpy);
    wusleep(MINIATURIZE_ANIMATION_DELAY_T);

    XDrawLines(dpy, scr->root_win, scr->frame_gc, points, 5, CoordModeOrigin);
    XUngrabServer(dpy);
    cx += xstep;
    cy += ystep;
    cw += wstep;
    ch += hstep;
    if (angle >= final_angle)
      break;

  }
  XFlush(dpy);
#undef FRAMES
}

static void animateResizeZoom(WScreen *scr, int x, int y, int w, int h,
                              int fx, int fy, int fw, int fh, int steps)
{
#define FRAMES (MINIATURIZE_ANIMATION_FRAMES_Z)
  float cx[FRAMES], cy[FRAMES], cw[FRAMES], ch[FRAMES];
  float xstep, ystep, wstep, hstep;
  int i, j;

  xstep = (float)(fx - x) / steps;
  ystep = (float)(fy - y) / steps;
  wstep = (float)(fw - w) / steps;
  hstep = (float)(fh - h) / steps;

  for (j = 0; j < FRAMES; j++) {
    cx[j] = (float)x;
    cy[j] = (float)y;
    cw[j] = (float)w;
    ch[j] = (float)h;
  }
  XGrabServer(dpy);
  for (i = 0; i < steps; i++) {
    for (j = 0; j < FRAMES; j++) {
      XDrawRectangle(dpy, scr->root_win, scr->frame_gc,
                     (int)cx[j], (int)cy[j], (int)cw[j], (int)ch[j]);
    }
    XFlush(dpy);
    wusleep(MINIATURIZE_ANIMATION_DELAY_Z);

    for (j = 0; j < FRAMES; j++) {
      XDrawRectangle(dpy, scr->root_win, scr->frame_gc,
                     (int)cx[j], (int)cy[j], (int)cw[j], (int)ch[j]);
      if (j < FRAMES - 1) {
        cx[j] = cx[j + 1];
        cy[j] = cy[j + 1];
        cw[j] = cw[j + 1];
        ch[j] = ch[j + 1];
      } else {
        cx[j] += xstep;
        cy[j] += ystep;
        cw[j] += wstep;
        ch[j] += hstep;
      }
    }
  }

  for (j = 0; j < FRAMES; j++)
    XDrawRectangle(dpy, scr->root_win, scr->frame_gc, (int)cx[j], (int)cy[j], (int)cw[j], (int)ch[j]);
  XFlush(dpy);
  wusleep(MINIATURIZE_ANIMATION_DELAY_Z);

  for (j = 0; j < FRAMES; j++)
    XDrawRectangle(dpy, scr->root_win, scr->frame_gc, (int)cx[j], (int)cy[j], (int)cw[j], (int)ch[j]);

  XUngrabServer(dpy);
}

#undef FRAMES

int wGetAnimationGeometry(WWindow *wwin, int *ix, int *iy, int *iw, int *ih)
{
  if (wwin->screen->flags.startup || wPreferences.no_animations
      || wwin->flags.skip_next_animation || wwin->icon == NULL)
    return 0;

  if (!wPreferences.disable_miniwindows && !wwin->flags.net_handle_icon) {
    *ix = wwin->icon_x;
    *iy = wwin->icon_y;
    *iw = wwin->icon->core->width;
    *ih = wwin->icon->core->height;
  } else {
    if (wwin->flags.net_handle_icon) {
      *ix = wwin->icon_x;
      *iy = wwin->icon_y;
      *iw = wwin->icon_w;
      *ih = wwin->icon_h;
    } else {
      *ix = 0;
      *iy = 0;
      *iw = wwin->screen->width;
      *ih = wwin->screen->height;
    }
  }
  return 1;
}

void wAnimateResize(WScreen *scr, int x, int y, int w, int h, int fx, int fy, int fw, int fh)
{
  int style = wPreferences.iconification_style;	/* Catch the value */
  int steps;

  if (style == WIS_NONE)
    return;

  if (style == WIS_RANDOM)
    style = rand() % 3;

  switch (style) {
  case WIS_TWIST:
    steps = MINIATURIZE_ANIMATION_STEPS_T;
    if (steps > 0)
      animateResizeTwist(scr, x, y, w, h, fx, fy, fw, fh, steps);
    break;
  case WIS_FLIP:
    steps = MINIATURIZE_ANIMATION_STEPS_F;
    if (steps > 0)
      animateResizeFlip(scr, x, y, w, h, fx, fy, fw, fh, steps);
    break;
  case WIS_ZOOM:
  default:
    steps = MINIATURIZE_ANIMATION_STEPS_Z;
    if (steps > 0)
      animateResizeZoom(scr, x, y, w, h, fx, fy, fw, fh, steps);
    break;
  }
}

/* Do the animation while shading (called with what = SHADE) or unshading (what = UNSHADE). */
void wAnimateShade(WWindow *wwin, Bool what)
{
  int y, s, w, h;
  time_t time0 = time(NULL);

  if (wwin->flags.skip_next_animation || wPreferences.no_animations)
    return;

  switch (what) {
  case SHADE:
    if (!wwin->screen->flags.startup) {
      /* do the shading animation */
      h = wwin->frame->core->height;
      s = h / SHADE_STEPS;
      if (s < 1)
        s = 1;
      w = wwin->frame->core->width;
      y = wwin->frame->top_width;
      while (h > wwin->frame->top_width + 1) {
        XMoveWindow(dpy, wwin->client_win, 0, y);
        XResizeWindow(dpy, wwin->frame->core->window, w, h);
        XFlush(dpy);

        if (time(NULL) - time0 > MAX_ANIMATION_TIME)
          break;

        if (SHADE_DELAY > 0)
          wusleep(SHADE_DELAY * 1000L);
        else
          wusleep(10);
        h -= s;
        y -= s;
      }
      XMoveWindow(dpy, wwin->client_win, 0, wwin->frame->top_width);
    }
    break;

  case UNSHADE:
    h = wwin->frame->top_width + wwin->frame->bottom_width;
    y = wwin->frame->top_width - wwin->client.height;
    s = abs(y) / SHADE_STEPS;
    if (s < 1)
      s = 1;
    w = wwin->frame->core->width;
    XMoveWindow(dpy, wwin->client_win, 0, y);
    if (s > 0) {
      while (h < wwin->client.height + wwin->frame->top_width + wwin->frame->bottom_width) {
        XResizeWindow(dpy, wwin->frame->core->window, w, h);
        XMoveWindow(dpy, wwin->client_win, 0, y);
        XFlush(dpy);
        if (SHADE_DELAY > 0)
          wusleep(SHADE_DELAY * 2000L / 3);
        else
          wusleep(10);
        h += s;
        y += s;

        if (time(NULL) - time0 > MAX_ANIMATION_TIME)
          break;
      }
    }
    XMoveWindow(dpy, wwin->client_win, 0, wwin->frame->top_width);
    break;
  }
}

#endif /* USE_ANIMATIONS */

