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

#ifndef _GTKWIDGETVIEW_H_
#define _GTKWIDGETVIEW_H_

#import <AppKit/AppKit.h>
#import "XEmbeddedView.h"

#define GCHAR2NSSTRING(s) [[[NSString alloc]initWithUTF8String:s]autorelease]

@interface GTKWidgetView : XEmbeddedView

- (void) executeInGTK:(void (^)(void)) block;

@end

#endif // _GTKWIDGETVIEW_H_

