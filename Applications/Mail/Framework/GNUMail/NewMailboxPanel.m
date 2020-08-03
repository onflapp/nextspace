/*
**  NewMailboxPanel.m
**
**  Copyright (c) 2001-2005 Ludovic Marcotte
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

#include "NewMailboxPanel.h"

#include "Constants.h"
#include "LabelWidget.h"

@implementation NewMailboxPanel

- (void) dealloc
{
  NSDebugLog(@"NewMailboxPanel: -dealloc");

  RELEASE(mailboxNameLabel);
  RELEASE(mailboxNameField);
  [super dealloc];
}


//
//
//
- (void) layoutPanel
{
  NSButton *okButton, *cancelButton;
  NSImageView *icon;

  icon = [[NSImageView alloc] initWithFrame: NSMakeRect(10,90,48,48)];
  [icon setImageAlignment: NSImageAlignCenter];
  [icon setImage: [NSImage imageNamed: @"GNUMail.tiff"]];
  [icon setImageFrameStyle: NSImageFrameNone];
  [icon setEditable: NO];
  [[self contentView] addSubview: icon];
  RELEASE(icon);
  
  mailboxNameLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(65,90,280,TextFieldHeight)
				  label: _(@"Please enter the name of the new Mailbox:")];
  [[self contentView] addSubview: mailboxNameLabel];
  RETAIN(mailboxNameLabel);
  
  mailboxNameField = [[NSTextField alloc] initWithFrame: NSMakeRect(20,50,305,TextFieldHeight)];
  [mailboxNameField setSelectable: YES];
  [mailboxNameField setTarget: [self windowController]];
  [mailboxNameField setAction: @selector(okClicked:)];
  [[self contentView] addSubview: mailboxNameField];
    
  cancelButton = [[NSButton alloc] initWithFrame: NSMakeRect(165,10,75,ButtonHeight)];
  [cancelButton setButtonType: NSMomentaryPushButton];
  [cancelButton setKeyEquivalent: @"\e"];
  [cancelButton setTitle: _(@"Cancel")];
  [cancelButton setTarget: [self windowController]];
  [cancelButton setAction: @selector(cancelClicked:)];
  [[self contentView] addSubview: cancelButton];
  RELEASE(cancelButton);

  
  okButton = [[NSButton alloc] initWithFrame:  NSMakeRect(250,10,75,ButtonHeight)];
  [okButton setButtonType: NSMomentaryPushButton];
  [okButton setKeyEquivalent: @"\r"];
  [okButton setImagePosition: NSImageRight];
  [okButton setImage: [NSImage imageNamed: @"common_ret"]];
  [okButton setAlternateImage: [NSImage imageNamed: @"common_retH"]];
  [okButton setTitle: _(@"OK")];
  [okButton setTarget: [self windowController]];
  [okButton setAction: @selector(okClicked:)];
  [[self contentView] addSubview: okButton];
  RELEASE(okButton);

  // We set the initial responder and the next key views
  [self setInitialFirstResponder: mailboxNameField];
  [mailboxNameField setNextKeyView: cancelButton];
  [cancelButton setNextKeyView: okButton];
  [okButton setNextKeyView: mailboxNameField];
}

@end
