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
NSLock* GTKWidgetView_gtk_loop_queue_lock;

gint handler_idle(gpointer data) {
  [GTKWidgetView_gtk_loop_queue_lock lock];

  if ([GTKWidgetView_gtk_loop_queue count] > 0) {

    for (void (^func)(void) in GTKWidgetView_gtk_loop_queue) {
      func();
    }
    [GTKWidgetView_gtk_loop_queue removeAllObjects];
  }
  [GTKWidgetView_gtk_loop_queue_lock unlock];
  
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

- (id) initWithFrame:(NSRect)r {
  self = [super initWithFrame:r];
  widget = NULL;
  plug = NULL;
  
  
  return self;
}

- (void) createXWindow {
  [self startGTKEventLoop];

  [self executeInGTK:^{
    [self createWidgetPlug];
  }];
}

- (void) destroyXWindow {
  [self destroyWidget];
  [super destroyXWindow];
}

- (void) executeInGTK:(void (^)(void)) block {
  [GTKWidgetView_gtk_loop_queue_lock lock];
  [GTKWidgetView_gtk_loop_queue addObject:block];
  [GTKWidgetView_gtk_loop_queue_lock unlock];
}

- (GtkWidget*) createWidgetForGTK {
  return NULL;
}

- (void) startGTKEventLoop {
  if (GTKWidgetView_gtk_loop_queue) return;
  
  GTKWidgetView_gtk_loop_queue = [[NSMutableArray alloc] init];
  GTKWidgetView_gtk_loop_queue_lock = [[NSLock alloc] init];
  
  [NSThread detachNewThreadSelector:@selector(GTKEventLoopProcess) toTarget:self withObject:nil];
}

- (void) GTKEventLoopProcess {
  gtk_init(0, NULL);
  
  gdk_threads_add_timeout(100, handler_idle, NULL);
  gtk_main();
}

- (void) createWidgetPlug {        
  plug = gtk_plug_new(0);
    
  //GtkWidget *main_window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  //gtk_window_set_default_size(GTK_WINDOW(main_window), 800, 600);
     
   GtkWidget *widget = [self createWidgetForGTK];
   gtk_container_add(GTK_CONTAINER(plug), GTK_WIDGET(widget));
     
   g_signal_connect(G_OBJECT(widget), "button-press-event", G_CALLBACK(handler_focus_event), self);
     
   gtk_widget_show_all(plug);
    
   Window xwin = gtk_plug_get_id(plug);
     
   //GdkWindow* gw = gtk_widget_get_window(main_window);
   //Window xwin = gdk_x11_window_get_xid(gw);
  
   [self performSelectorOnMainThread:@selector(remapXWindow:) withObject:[NSNumber numberWithInteger:xwin] waitUntilDone:NO];
}

- (void) destroyWidget {
  if (plug) {
    gtk_window_close(plug); // should probably be called from the GTK thread
    // this is a bit hacky, but it seems to be the only way to give GTK chance to close the window normaly
    [NSThread sleepForTimeInterval:0.1]; //postpone the main loop for a bit
  }
  
  widget = NULL;
  plug = NULL;
}


@end
