/*
**  PreferencesWindow.m
**
**  Copyright (c) 2001-2005
**
**  Author: Ludovic Marcotte <ludovic@Sophos.ca>
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

#include "PreferencesWindow.h"

#include "Constants.h"


//
//
//
@implementation PreferencesWindow

- (void) dealloc
{
  RELEASE(box);
  RELEASE(matrix);
  RELEASE(scrollView);
  RELEASE(expert);
  [super dealloc];
}

//
//
//
- (void) layoutWindow
{
  NSButton *ok, *apply, *cancel;
  NSButtonCell *cell;

  box = [[NSBox alloc] initWithFrame: NSMakeRect(8,41,455,260)];
  [box setTitlePosition: NSAtTop];
  [box setBorderType: NSGrooveBorder];
  [[self contentView] addSubview: box];  
  
  cell = [[NSButtonCell alloc] init];
  AUTORELEASE(cell);
  [cell setHighlightsBy: NSChangeBackgroundCellMask];
  [cell setShowsStateBy: NSChangeBackgroundCellMask];
  [cell setImagePosition: NSImageAbove];
  
  matrix = [[NSMatrix alloc] initWithFrame: NSMakeRect(8,306,455,86)
			     mode: NSRadioModeMatrix
			     prototype: cell
			     numberOfRows: 1
			     numberOfColumns: 10];
  [matrix setTarget: [self windowController]];
  [matrix setCellSize: NSMakeSize(64,64)];
  [matrix setAction: @selector(handleCellAction:)];
  
  scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(8,306,455,86)];
  [scrollView setBorderType: NSBezelBorder];
  [scrollView setHasHorizontalScroller: YES];
  [scrollView setHasVerticalScroller: NO];
  [scrollView setDocumentView: matrix];  
  [[self contentView] addSubview: scrollView];

  // We create the buttons
  expert = [[NSButton alloc] initWithFrame:NSMakeRect(8,8,80,ButtonHeight)];
  [expert setTitle: _(@"Expert")];
  [expert setTarget: [self windowController]];
  [expert setAction: @selector(expertClicked:)];
  [[self contentView] addSubview: expert];

  apply = [[NSButton alloc] initWithFrame:NSMakeRect(230,8,75,ButtonHeight)];
  [apply setTitle: _(@"Apply")];
  [apply setTarget: [self windowController]];
  [apply setAction: @selector(savePreferences:)];
  [[self contentView] addSubview: apply];
  RELEASE(apply);

  cancel = [[NSButton alloc] initWithFrame:NSMakeRect(310,8,75,ButtonHeight)];
  [cancel setTitle: _(@"Cancel")];
  [cancel setKeyEquivalent: @"\e"];
  [cancel setTarget: [self windowController]];
  [cancel setAction: @selector(cancelClicked:)];
  [[self contentView] addSubview:  cancel];
  RELEASE(cancel);
  
  ok = [[NSButton alloc] initWithFrame:NSMakeRect(390,8,75,ButtonHeight)];
  [ok setButtonType: NSMomentaryPushButton];
  [ok setKeyEquivalent: @"\r"];
  [ok setImagePosition: NSImageRight];
  [ok setImage: [NSImage imageNamed: @"common_ret"]];
  [ok setAlternateImage: [NSImage imageNamed: @"common_retH"]];
  [ok setTitle: _(@"OK")];
  [ok setTarget: [self windowController]];
  [ok setAction: @selector(saveAndClose:)];
  [[self contentView] addSubview: ok];
  RELEASE(ok);
}

@end
