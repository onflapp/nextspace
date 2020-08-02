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

@interface GTKWidgetView ()
{
  GtkWidget* widget;
  Display* xdisplay;
  Window xwindowid;
}

@end

gint handler_event(GtkWidget* widget, GdkEventButton* evt, gpointer func_data) 
{
  NSView* view = (NSView*)func_data;
  NSWindow* win = [view window];
  
  [win makeKeyAndOrderFront:nil];
  [win makeFirstResponder:view];

  return FALSE;
}

@implementation GTKWidgetView

- (id) initWithFrame:(NSRect)r 
{
  self = [super initWithFrame:r];
  
  xwindowid = -1;
  
  return self;
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
}

- (BOOL) acceptsFirstResponder
{
  return YES;
}

- (BOOL) becomeFirstResponder
{
  if (widget) {
    gtk_widget_grab_focus(widget);
  }
  return TRUE;
}

- (BOOL) resignFirstResponder
{
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

  GtkWidget* main_window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  gtk_widget_realize(main_window);
  
  gtk_container_add(GTK_CONTAINER(main_window), GTK_WIDGET(widget));

  Window xw = (Window)[[self window]windowRef];
  GdkDisplay* gd = gdk_display_get_default();
  Display* xd = gdk_x11_display_get_xdisplay(gd);
  GdkWindow* gw = gtk_widget_get_window(main_window);
  Window xid = gdk_x11_window_get_xid(gw);
  
  NSRect r = [self convertToNativeWindowRect];
  
  XReparentWindow(xd, xid, xw, r.origin.x, r.origin.y);
  XResizeWindow(xd, xid, r.size.width, r.size.height);
  XFlush(xd);
  
  xdisplay = xd;
  xwindowid = xid;

  g_signal_connect(G_OBJECT(widget), "button-press-event", G_CALLBACK(handler_event), self);
  
  gtk_widget_show_all(main_window);
    
  [self startProcessingEvents];
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
