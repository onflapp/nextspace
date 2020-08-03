/*
   Project: WebBrowser

   Copyright (C) 2020 Free Software Foundation

   Author: root

   Created: 2020-07-31 13:40:44 +0300 by root

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import "GTKWidgetView.h"
#include <gtk/gtk.h>
#include <gtk/gtkx.h>

static BOOL gtkwdigets_gtk_initialized;

@interface GTKWidgetView ()
{
  GtkWidget* widget;
  GtkWidget* gwindow;
  Display* xdisplay;
  Window xwindowid;
  BOOL hasfocus;
}

@end

gint handler_realize(GtkWidget* widget, gpointer user)
{
  NSLog(@"realize");
  gtk_widget_set_window(widget, (GdkWindow*)user);

  return FALSE;
}

gint handler_event(GtkWidget* widget, GdkEventButton* evt, gpointer func_data) 
{
  NSView* view = (NSView*)func_data;
  NSWindow* win = [view window];
  
  //[win makeKeyAndOrderFront:nil];
  [win makeFirstResponder:view];

  return FALSE;
}

@implementation GTKWidgetView

+ (void) initialize
{
  if (!gtkwdigets_gtk_initialized) {
    NSLog(@"GTKWidgetView: gtk_init called for the very first time");
    gtk_init(NULL, 0);
    gtkwdigets_gtk_initialized++;
  }
}

- (id) initWithFrame:(NSRect)r 
{
  self = [super initWithFrame:r];
  
  xwindowid = -1;
  
  return self;
}

- (void) dealloc
{
  [super dealloc];
}

- (GtkWidget*) createWidget
{
  return NULL;
}

- (void) viewDidMoveToWindow {
  if ([self window]) {
    if (!widget) { 
      widget = [self createWidget];
      [self mapWidgetToWindow];
    }
  }
  else {
    if (widget) {
      [self unmapWidgetFromWindow];
      widget = NULL;
      xwindowid = 0;
    }
  }
}

- (BOOL) acceptsFirstResponder
{
  return YES;
}

- (BOOL) becomeFirstResponder
{
  if (widget) {
    if (!hasfocus) {
      XSetInputFocus(xdisplay, xwindowid, RevertToNone, CurrentTime);
      hasfocus = TRUE;
    }
  }
  return TRUE;
}

- (BOOL) resignFirstResponder
{
  hasfocus = FALSE;
  return TRUE;
}

- (void) resizeWithOldSuperviewSize:(NSSize) sz
{
  [super resizeWithOldSuperviewSize:sz];

  if (!widget) return;
  if (!xwindowid) return;
  if (![self window]) return;

  NSRect r = [self convertToNativeWindowRect];
  
  XMoveResizeWindow(xdisplay, xwindowid, r.origin.x, r.origin.y, r.size.width, r.size.height);
}

- (NSRect) convertToNativeWindowRect
{
  NSRect r = [self convertRect:[self bounds] toView:nil];
  NSInteger x = (NSInteger)r.origin.x;
  NSInteger y = (NSInteger)r.origin.y;
  NSInteger w = (NSInteger)r.size.width;
  NSInteger h = (NSInteger)r.size.height;
  
  y = [[[self window] contentView] bounds].size.height - r.size.height - r.origin.y;
  y += 10;
  
  return NSMakeRect(x, y, w, h);
}

- (void) drawRect:(NSRect)r {
  [[NSColor redColor] setFill];
  NSRectFill(r);
}

- (void) mapWidgetToWindow 
{
  if (!widget) return;
  if (![self window]) return;

  Window xw = (Window)[[self window]windowRef];
  GdkDisplay* gd = gdk_display_get_default();
  Display* xd = gdk_x11_display_get_xdisplay(gd);

  GtkWidget* main_window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_widget_realize(main_window);

  GdkWindow* gw = gtk_widget_get_window(main_window);
  
  /*
  int xs = DefaultScreen(xd);
  Window xxw = XCreateSimpleWindow(xd, RootWindow(xd, xs), 10, 10, 100, 100, 1, BlackPixel(xd, xs), WhitePixel(xd, xs));
  XMapWindow(xd, xxw);

  GdkWindow* gw = gdk_x11_window_foreign_new_for_display(gd, xxw);
  GtkWidget* main_window = gtk_widget_new(GTK_TYPE_WINDOW, NULL);
  
  g_signal_connect(main_window, "realize", G_CALLBACK(handler_realize), gw);
  gtk_widget_set_has_window(main_window, TRUE);
  
  gtk_widget_realize(main_window);
  [self startProcessingEvents];
  */
  
  gtk_container_add(GTK_CONTAINER(main_window), GTK_WIDGET(widget));

  Window xid = gdk_x11_window_get_xid(gw);
  
  NSRect r = [self convertToNativeWindowRect];
  
  XReparentWindow(xd, xid, xw, r.origin.x, r.origin.y);
  XResizeWindow(xd, xid, r.size.width, r.size.height);
  XFlush(xd);
 
  gwindow = main_window; 
  xdisplay = xd;
  xwindowid = xid;

  g_signal_connect(G_OBJECT(widget), "button-press-event", G_CALLBACK(handler_event), self);
  
  gtk_widget_show_all(main_window);
    
  [self startProcessingEvents];
}

- (void) unmapWidgetFromWindow {
  if (!widget) return;
  
  //XDestroyWindow(xdisplay, xwindowid);
  
  [self processPendingEvents];
  
  //GtkWidget* main_window = gtk_widget_get_parent_window(widget);
  //gtk_window_close(main_window);
}

- (void) processPendingEvents {
  while(gtk_events_pending()) {
    gtk_main_iteration();
  }
}

- (void) startProcessingEvents
{
  while(gtk_events_pending()) 
  {
    gtk_main_iteration();
  }
  [self performSelector:@selector(startProcessingEvents) withObject:nil afterDelay:0.1];  
}

- (void) stopProcessingEvents
{
}

@end
