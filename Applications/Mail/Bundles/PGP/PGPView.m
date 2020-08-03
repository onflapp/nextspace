/*
**  PGPView.m
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
**  You should have received a copy of the GNU General Public License
**  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "PGPView.h"

#include "Constants.h"
#include "LabelWidget.h"

@implementation PGPView

- (id) initWithParent: (id) theParent
{
  self = [super init];

  parent = theParent;

  return self;
}


//
//
//
- (void) dealloc
{
  RELEASE(versionLabel);
  RELEASE(gpgPathField);
  RELEASE(userEMailAddressField);
  RELEASE(useFromForSigning);
  RELEASE(alwaysSign);
  RELEASE(alwaysEncrypt);
  RELEASE(alwaysUseMultipartPGP);
  RELEASE(removePassphraseFromCacheButton);
  RELEASE(removePassphraseFromCacheField);
  [super dealloc];
}


//
//
//
- (void) layoutView
{
  LabelWidget *label;

  //
  // Version of the Bundle
  //
  versionLabel = [LabelWidget labelWidgetWithFrame: NSMakeRect(5, 210, 430, TextFieldHeight)
			      label: @"Version: v0.0.0"
			      alignment: NSRightTextAlignment];
  RETAIN(versionLabel);
  [self addSubview: versionLabel];
  
  //
  // GPG path
  //
  label =  [LabelWidget labelWidgetWithFrame: NSMakeRect(5, 170, 170, TextFieldHeight)
			label: _(@"GPG/PGP executable path:")
			alignment: NSRightTextAlignment];
  [self addSubview: label];
  
  gpgPathField = [[NSTextField alloc] initWithFrame: NSMakeRect(185,170,235,TextFieldHeight)];
  [self addSubview: gpgPathField];
  

  //
  // User ID
  //
  label =  [LabelWidget labelWidgetWithFrame: NSMakeRect(5, 140, 170, TextFieldHeight)
			label: _(@"User E-Mail address:")
			alignment: NSRightTextAlignment];
  [self addSubview: label];
  
  userEMailAddressField = [[NSTextField alloc] initWithFrame: NSMakeRect(185,140,235,TextFieldHeight)];
  [self addSubview: userEMailAddressField];


  //
  // Use FROM for signing
  //
  useFromForSigning = [[NSButton alloc] initWithFrame: NSMakeRect(5,105,300,ButtonHeight)];
  [useFromForSigning setButtonType: NSSwitchButton];
  [useFromForSigning setBordered: NO];
  [useFromForSigning setTitle: _(@"Use FROM E-Mail address for signing")];
  [self addSubview: useFromForSigning];	 


  //
  // Always encrypt
  //
  alwaysEncrypt = [[NSButton alloc] initWithFrame: NSMakeRect(5,80,300,ButtonHeight)];
  [alwaysEncrypt setButtonType: NSSwitchButton];
  [alwaysEncrypt setBordered: NO];
  [alwaysEncrypt setTitle: _(@"Always encrypt messages")];
  [self addSubview: alwaysEncrypt];

  //
  // Always sign
  //
  alwaysSign = [[NSButton alloc] initWithFrame: NSMakeRect(5,55,300,ButtonHeight)];
  [alwaysSign setButtonType: NSSwitchButton];
  [alwaysSign setBordered: NO];
  [alwaysSign setTitle: _(@"Always sign messages")];
  [self addSubview: alwaysSign];


  //
  // Always use Multipart PGP style
  //
  alwaysUseMultipartPGP = [[NSButton alloc] initWithFrame: NSMakeRect(5,30,300,ButtonHeight)];
  [alwaysUseMultipartPGP setButtonType: NSSwitchButton];
  [alwaysUseMultipartPGP setBordered: NO];
  [alwaysUseMultipartPGP setTitle: _(@"Always use Multipart PGP style")];
  [self addSubview: alwaysUseMultipartPGP];


  //
  // Remove passphrase after X minutes
  //
  removePassphraseFromCacheButton = [[NSButton alloc] initWithFrame: NSMakeRect(5,5,260,ButtonHeight)];
  [removePassphraseFromCacheButton setButtonType: NSSwitchButton];
  [removePassphraseFromCacheButton setBordered: NO];
  [removePassphraseFromCacheButton setTitle: _(@"Remove passphrase from cache after")];
  [removePassphraseFromCacheButton setTarget: parent];
  [removePassphraseFromCacheButton setAction: @selector(removePassphraseFromCacheButtonClicked:)];
  [self addSubview: removePassphraseFromCacheButton];

  removePassphraseFromCacheField = [[NSTextField alloc] initWithFrame: NSMakeRect(275,5,50,TextFieldHeight)];
  [self addSubview: removePassphraseFromCacheField];
  
  label =  [LabelWidget labelWidgetWithFrame: NSMakeRect(335, 5, 100, TextFieldHeight)
			label: _(@"minutes")
			alignment: NSLeftTextAlignment];
  [self addSubview: label];
}

@end
