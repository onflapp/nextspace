/*
**  NewMailboxPanelController.m
**
**  Copyright (c) 2001-2006 Ludovic Marcotte
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

#include "NewMailboxPanelController.h"

#include "Constants.h"

#ifndef MACOSX
#include "NewMailboxPanel.h"
#endif

#include "Utilities.h"


//
//
//
@implementation NewMailboxPanelController

- (id) initWithWindowNibName: (NSString *) windowNibName
{
#ifdef MACOSX
  
  self = [super initWithWindowNibName: windowNibName];
 
#else
  NewMailboxPanel *aNewMailboxPanel;

  aNewMailboxPanel = [[NewMailboxPanel alloc] initWithContentRect: NSMakeRect(200,200,345,150)
					      styleMask: NSTitledWindowMask|NSMiniaturizableWindowMask
					      backing: NSBackingStoreBuffered
					      defer: YES];
  
  self = [super initWithWindow: aNewMailboxPanel];
  
  [aNewMailboxPanel layoutPanel];
  [aNewMailboxPanel setDelegate: self];
  
  // We link our outlets
  mailboxNameField = aNewMailboxPanel->mailboxNameField;
  RELEASE(aNewMailboxPanel);
#endif

  // We set our window title
  [[self window] setTitle: _(@"New Mailbox")];

  return self;
}


//
// action methods
//
- (IBAction) okClicked: (id) sender
{ 
  [NSApp stopModal];
  [self close];
}


//
//
//
- (IBAction) cancelClicked: (id) sender
{
  [NSApp stopModalWithCode: NSRunAbortedResponse];
  [self close];
}


//
// delegate methods
//
- (void) windowWillClose: (NSNotification *) theNotification
{
  // We do nothing
}

//
// access methods
//
- (NSTextField *) mailboxNameField
{
  return mailboxNameField;
}

@end
