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

NSMutableArray* GTKWidgetView_gtk_loop_queue;

gint handler_idle(gpointer data) {
  if ([GTKWidgetView_gtk_loop_queue count] == 0) return 1;

  NSLog(@"exec");
  for (void (^func)(void) in GTKWidgetView_gtk_loop_queue) {
    func();
  }

  [GTKWidgetView_gtk_loop_queue removeAllObjects];
  gdk_threads_add_timeout(100, handler_idle, NULL);

  return 1;
}

gint handler_focus_event(GtkWidget* widget, GdkEventButton* evt, gpointer func_data) {
  NSView* view = (NSView*)func_data;

  [view performSelectorOnMainThread:@selector(activateXWindow) withObject:nil waitUntilDone:NO];
  return 0;
}

@interface GTKWidgetView ()
{
  GtkWidget* widget;
  GtkWidget* plug;
}

@end

@implementation GTKWidgetView

- (void) viewDidMoveToWindow {
  [self startGTKEventLoop];

  if ([self window]) {
    if (!widget) {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                            selector:@selector(deactivateXWindow) 
                                                name:NSWindowDidResignKeyNotification
                                              object:[self window]];
    [self executeInGTK:^{
      [self createWidgetPlug];
     }];
    }
  }
  else {
    if (widget) {
      [self destroyWidgets];
      NSLog(@"close");
    }
  }
}

- (void) executeInGTK:(void (^)(void)) block {
  NSLog(@"queue");
  [GTKWidgetView_gtk_loop_queue addObject:block];
}

- (GtkWidget*) createWidget {
  return NULL;
}

- (void) startGTKEventLoop {
  if (GTKWidgetView_gtk_loop_queue) return;
  GTKWidgetView_gtk_loop_queue = [[NSMutableArray alloc] init];
  
  [NSThread detachNewThreadSelector:@selector(GTKEventLoopProcess) toTarget:self withObject:nil];
}

- (void) GTKEventLoopProcess {
  NSLog(@"start");
  gtk_init(0, NULL);
  
  gdk_threads_add_timeout(100, handler_idle, NULL);
  gtk_main();
  
  NSLog(@"end");
}

- (void) createWidgetPlug {        
  plug = gtk_plug_new(0);
    
  //GtkWidget *main_window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  //gtk_window_set_default_size(GTK_WINDOW(main_window), 800, 600);
     
   GtkWidget *widget = [self createWidget];
   gtk_container_add(GTK_CONTAINER(plug), GTK_WIDGET(widget));
     
   g_signal_connect(G_OBJECT(widget), "button-press-event", G_CALLBACK(handler_focus_event), self);
     
   gtk_widget_show_all(plug);
    
   Window xwin = gtk_plug_get_id(plug);
     
   //GdkWindow* gw = gtk_widget_get_window(main_window);
   //Window xwin = gdk_x11_window_get_xid(gw);
  
   NSLog(@"xwin:%x", xwin);
   [self performSelectorOnMainThread:@selector(remapXWindow:) withObject:xwin waitUntilDone:NO];
}

- (void) destroyWidgets {
  widget = NULL;
  plug = NULL;
  
  [self unmapXWindow];
}


@end
