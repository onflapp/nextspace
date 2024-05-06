/* -*- mode: objc -*- */
//
// Project: Preferences
//
// Copyright (C) 2024 OnFlApp
//
// This application is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public
// License as published by the Free Software Foundation; either
// version 2 of the License, or (at your option) any later version.
//
// This application is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Library General Public License for more details.
//
// You should have received a copy of the GNU General Public
// License along with this library; if not, write to the Free
// Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
//

#import <AppKit/NSApplication.h>
#import <AppKit/NSNibLoading.h>
#import <AppKit/NSScrollView.h>
#import <AppKit/NSScroller.h>
#import <AppKit/NSButton.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSPopUpButton.h>

#import "Touch.h"

static NSBundle                 *bundle = nil;
static NSUserDefaults           *defaults = nil;

@implementation Touch

- (id)init
{
  self = [super init];
  
  defaults = [NSUserDefaults standardUserDefaults];

  bundle = [NSBundle bundleForClass:[self class]];
  NSString *imagePath = [bundle pathForResource:@"Touch" ofType:@"tiff"];
  image = [[NSImage alloc] initWithContentsOfFile:imagePath];

  return self;
}

- (void)dealloc
{
  NSLog(@"Touch -dealloc");

  [image release];

  if (view) {
    [view release];
  }
  
  [super dealloc];
}

- (void)awakeFromNib
{
  [view retain];
  [window release];
}

- (NSView *)view
{
  if (view == nil)
    {
      if (![NSBundle loadNibNamed:@"Touch" owner:self])
        {
          NSLog (@"Touch.preferences: Could not load NIB, aborting.");
          return nil;
        }
    }
  
  return view;
}

- (NSString *)buttonCaption
{
  return @"Touch Preferences";
}

- (NSImage *)buttonImage
{
  return image;
}

@end
