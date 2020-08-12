/*
   Project: WebBrowser

   Copyright (C) 2020 Free Software Foundation

   Author: root

   Created: 2020-08-08 14:25:54 +0300 by root

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

#import "XEmbeddedView.h"
#include "xembed.h"

@implementation XEmbeddedView

- (id) initWithFrame:(NSRect)r {
  self = [super initWithFrame:r];
  xwindowid = 0;
  xdisplay = NULL;
  return self;
}

- (void) viewDidMoveToWindow {
  if ([self window]) {
    if (xwindowid == 0) {
      [[NSNotificationCenter defaultCenter] addObserver:self 
                                              selector:@selector(deactivateXWindow) 
                                                  name:NSWindowDidResignKeyNotification
                                                object:[self window]];
                                               
      [[NSNotificationCenter defaultCenter] addObserver:self 
                                              selector:@selector(destroyXWindow) 
                                                  name:NSWindowWillCloseNotification
                                                object:[self window]];
                                                
      [self createXWindow];
    }
  }
  else {
    if (xwindowid != 0) {
      [[NSNotificationCenter defaultCenter] removeObserver:self];
      [self destroyXWindow];
      //[self unmapXWindow];
    }
  }
}

- (void) createXWindow {
}

- (void) destroyXWindow {
  NSLog(@"==== xxxx");
  xwindowid = 0;
}

- (void) activateXWindow {
  NSWindow* win = [self window];
  if (!win) return;

  [win makeKeyAndOrderFront:self];  
  [win makeFirstResponder:self];
  
  if ([NSApp isActive] == NO) {
    [NSApp activateIgnoringOtherApps:YES];
  }
}

- (void) deactivateXWindow {
  [self resignFirstResponder];
}

- (BOOL) acceptsFirstResponder {
    NSLog(@"- accept");
    return YES;
}

- (BOOL) becomeFirstResponder {
  NSLog(@"- become");
  if (xdisplay && xwindowid) {
    sendxembed(xdisplay, xwindowid, XEMBED_FOCUS_IN, XEMBED_FOCUS_CURRENT, 0, 0);
    sendxembed(xdisplay, xwindowid, XEMBED_WINDOW_ACTIVATE, 0, 0, 0);
    XFlush(xdisplay);
  }
  return YES;
}

- (BOOL) resignFirstResponder {
  NSLog(@"- resign");
  if (xdisplay && xwindowid) {
    sendxembed(xdisplay, xwindowid, XEMBED_FOCUS_OUT, XEMBED_FOCUS_CURRENT, 0, 0);
    sendxembed(xdisplay, xwindowid, XEMBED_WINDOW_DEACTIVATE, 0, 0, 0);
    XFlush(xdisplay);
  }
  return YES;
}

- (void) resizeWithOldSuperviewSize:(NSSize) sz {
  [super resizeWithOldSuperviewSize:sz];

  if (!xwindowid || !xdisplay) return;
  if (![self window]) return;

  NSLog(@"resize");
  NSRect r = [self convertToNativeWindowRect];
  
  XMoveResizeWindow(xdisplay, xwindowid, r.origin.x, r.origin.y, r.size.width, r.size.height);
  XFlush(xdisplay);
}

- (NSRect) convertToNativeWindowRect {
  NSRect r = [self bounds];
  NSView* sv = [self superview];
  while (sv) {
    NSRect sr = [sv bounds];
    r.origin.x += sr.origin.x;
    r.origin.y += sr.origin.y;
    sv = [sv superview];
  }
  NSInteger x = (NSInteger)r.origin.x;
  NSInteger y = (NSInteger)r.origin.y;
  NSInteger w = (NSInteger)r.size.width;
  NSInteger h = (NSInteger)r.size.height;
  
  y = [[[self window] contentView] bounds].size.height - r.size.height - r.origin.y;

  return NSMakeRect(x, y, w, h);
}

/*
- (void) drawRect:(NSRect)r {
  [[NSColor redColor] setFill];
  NSRectFill(r);
}
*/

- (void) unmapXWindow {
  if (!xdisplay || !xwindowid) return;

  XDestroyWindow(xdisplay, xwindowid);
  XFlush(xdisplay);
  xdisplay = NULL;
  xwindowid = 0;
  NSLog(@"unmapped");
}

- (void) remapXWindow:(Window) xwin {  
  Window myxwindowid = [[self window]windowRef];
  xdisplay = XOpenDisplay(NULL);
  xwindowid = xwin;
  
  NSRect r = [self convertToNativeWindowRect];
  
  NSLog(@"%x - %x -> %x", xdisplay, xwindowid, myxwindowid);
    
  XReparentWindow(xdisplay, xwindowid, myxwindowid, r.origin.x, r.origin.y);
  XFlush(xdisplay);
  XResizeWindow(xdisplay, xwindowid, r.size.width, r.size.height);
  XMapWindow(xdisplay, xwindowid); 
  XFlush(xdisplay);
}

@end
