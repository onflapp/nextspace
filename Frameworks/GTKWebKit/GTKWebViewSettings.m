/*
   Project: GTKWebKit

   Copyright (C) 2020 Free Software Foundation

   Author: root

   Created: 2020-08-14 11:15:23 +0300 by root

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

#import "GTKWebViewSettings.h"
#include <webkit2/webkit2.h>

@implementation GTKWebViewSettings

- (id) init {
  if (self = [super init]) {
    _proxy = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (NSString*) description {
  return [_proxy description];
}

- (void) dealloc {
  [_proxy release];
  _proxy = nil;
  [super dealloc];
}


- (void) setDeveloperExtras:(BOOL) val {
  [_proxy setValue:[NSNumber numberWithBool:val] forKey:@"DEVELOPER_EXTRAS"];
}

- (BOOL) developerExtras {
  return [[_proxy valueForKey:@"DEVELOPER_EXTRAS"] boolValue];
}

- (void) setHardwareAccelerationPolicy:(NSInteger) val {
  [_proxy setValue:[NSNumber numberWithInteger:val] forKey:@"HARDWARE_ACCELERATION_POLICY"];
}

- (NSInteger) hardwareAccelerationPolicy {
  return [[_proxy valueForKey:@"HARDWARE_ACCELERATION_POLICY"] integerValue];
}

- (void) applyToGTKWebKitView:(WebKitWebView*) webview {
  WebKitSettings* settings = webkit_web_view_get_settings(webview);
  NSInteger apol = [self hardwareAccelerationPolicy];
  NSLog(@">>> %@", self);
  if (apol == 2) {
    webkit_settings_set_hardware_acceleration_policy(settings, WEBKIT_HARDWARE_ACCELERATION_POLICY_ON_DEMAND);
  }
  else if (apol == 1) {
    webkit_settings_set_hardware_acceleration_policy(settings, WEBKIT_HARDWARE_ACCELERATION_POLICY_ALWAYS);
  }
  else {
    webkit_settings_set_hardware_acceleration_policy(settings, WEBKIT_HARDWARE_ACCELERATION_POLICY_NEVER);
  }
  
  webkit_settings_set_enable_developer_extras(settings, [self developerExtras]);
}

- (void) loadFromGTKWebKitView:(WebKitWebView*) webview {
  WebKitSettings* settings = webkit_web_view_get_settings(webview);
  
  WebKitHardwareAccelerationPolicy apol = webkit_settings_get_hardware_acceleration_policy(settings);
  if (apol == WEBKIT_HARDWARE_ACCELERATION_POLICY_ON_DEMAND) {
    [self setHardwareAccelerationPolicy:2];  
  }
  else if (apol == WEBKIT_HARDWARE_ACCELERATION_POLICY_ALWAYS) {
    [self setHardwareAccelerationPolicy:1];
  }
  else if (apol == WEBKIT_HARDWARE_ACCELERATION_POLICY_NEVER) {
    [self setHardwareAccelerationPolicy:0];
  }
  
  [self setDeveloperExtras:webkit_settings_get_enable_developer_extras(settings)];
}
@end
