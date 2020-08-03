/*
**  Constants.m
**
**  Copyright (c) 2003-2007 Ludovic Marcotte
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

#import <Foundation/NSString.h>

//
// Notifications used in GNUMail
//
NSString *AccountsHaveChanged =          @"AccountsHaveChanged";
NSString *FiltersHaveChanged =           @"FiltersHaveChanged";
NSString *FontValuesHaveChanged =        @"FontValuesHaveChanged";
NSString *MessageThreadingNotification = @"MessageThreadingNotification";
NSString *ReloadMessageList =            @"ReloadMessageList";
NSString *TableColumnsHaveChanged =      @"TableColumnsHaveChanged";

//
// Operations and attributes for messages
//
NSString *FolderExpireDate = @"FolderExpireDate";
NSString *MessageData = @"MessageData";
NSString *MessageDestinationChangeEncoding = @"MessageDestinationChangeEncoding";
NSString *MessageDestinationFolder = @"MessageDestinationFolder";
NSString *MessageDestinationPasteboard = @"MessageDestinationPasteboard";
NSString *MessageDestinationStore = @"MessageDestinationStore";
NSString *MessageExpireDate = @"MessageExpireDate";
NSString *MessageFlags = @"MessageFlags";
NSString *MessageLoading = @"MessageLoading";
NSString *MessageNumber = @"MessageNumber";
NSString *MessageOperation = @"MessageOperation";
NSString *MessagePreloading = @"MessagePreloading";
NSString *MessageRedirecting = @"MessageRedirecting";
NSString *MessageViewing = @"MessageViewing";

//
// Pasteboard data types
//
NSString *MessagePboardType = @"MessagePboardType";
