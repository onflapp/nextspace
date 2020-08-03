/*
**  MailWindow.m
**
**  Copyright (c) 2001-2006 Ludovic Marcotte
**                2014      Riccardo Mottola
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
**          Riccardo Mottola <rm@gnu.org>
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import "MailWindow.h"

#import "ExtendedTextView.h"
#include "Constants.h"
#import "LabelWidget.h"

//
//
//
@implementation MailWindow

- (void) dealloc
{
  RELEASE(label);
  RELEASE(splitView);
  RELEASE(tableScrollView);
  RELEASE(textView);
  RELEASE(textScrollView);
  RELEASE(icon);
  [super dealloc];
}


//
//
//
- (void) layoutWindow
{
  NSRect mRect;

  mRect = NSMakeRect(0,0,562,230);
  
  // We first add our 'icon' image
  icon = [[NSButton alloc] initWithFrame: NSMakeRect(4,578,16,16)];
  [icon setImagePosition: NSImageOnly];
  [icon setImage: nil];
  [icon setTitle: @""];
  [icon setBordered: NO];
  [icon setTarget: [NSApp delegate]];
  [icon setAction: @selector(showConsoleWindow:)];
  [icon setAutoresizingMask: NSViewMinYMargin];
  [[self contentView] addSubview: icon];
    
  label = [LabelWidget labelWidgetWithFrame: NSMakeRect(24,575,500,20)
		       label: @""];
  RETAIN(label);
  [label setFont: [NSFont systemFontOfSize: 10]];
  [label setTextColor: [NSColor darkGrayColor]];
  [label setAutoresizingMask: NSViewMinYMargin];
  [[self contentView] addSubview: label];
  
  // We create our split view
  splitView = [[NSSplitView alloc] initWithFrame: NSMakeRect(5,5,602,570)];
  [splitView setVertical: NO];
  [splitView setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
  
  //
  // We create our table scroll view and our textview object.
  //
  tableScrollView = [[NSScrollView alloc] initWithFrame: mRect];
  [tableScrollView setBorderType: NSBezelBorder];
  [tableScrollView setHasHorizontalScroller: NO];
  [tableScrollView setHasVerticalScroller: YES];
  [tableScrollView setAutoresizingMask: NSViewWidthSizable|NSViewHeightSizable];
  
  textScrollView = [[NSScrollView alloc] initWithFrame: mRect];
  [textScrollView setBorderType: NSBezelBorder];
  [textScrollView setHasHorizontalScroller: NO];
  [textScrollView setHasVerticalScroller: YES];
 
  mRect = [[textScrollView contentView] frame];
  textView = [[ExtendedTextView alloc] init];
  [textView setFrame: mRect];
  [textView setTextContainerInset: NSMakeSize(5,5)];
  [textView setBackgroundColor: [NSColor textBackgroundColor]];
  [textView setRichText: YES];
  [textView setUsesFontPanel: YES];
  [textView setDelegate: [self windowController]];
  [textView setHorizontallyResizable: NO];
  [textView setVerticallyResizable: YES];
  [textView setMinSize: NSMakeSize (0, 0)];
  [textView setMaxSize: NSMakeSize (1E7, 1E7)];
  [textView setAutoresizingMask: NSViewHeightSizable|NSViewWidthSizable];
  [[textView textContainer] setContainerSize: NSMakeSize (mRect.size.width, 1E7)];

  [[textView textContainer] setWidthTracksTextView: YES];
  [textView setEditable: NO];
  [textView setString: @""];
  
  [textScrollView setDocumentView: textView];

  [splitView addSubview: tableScrollView];
  [splitView addSubview: textScrollView];

  //FIXME: This crash the app, but I'm not sure why.
  //[splitView adjustSubviews];
  
  [[self contentView] addSubview: splitView];
  [self setMinSize: NSMakeSize(600,470)];
}

@end
