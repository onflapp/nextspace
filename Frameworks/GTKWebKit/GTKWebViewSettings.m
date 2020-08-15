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
  RELEASE(_proxy);
  [super dealloc];
}

- (void) mergeFromDictionary:(NSDictionary*) dict {
  for (NSString* key in [dict allKeys]) {
    id val = [dict valueForKey:key];
    if (val) {
      [_proxy setValue:val forKey:key];
    }
  }
}

- (void) setUserAgent:(NSString*) val {
  [_proxy setValue:val forKey:@"USER_AGENT"];
}

- (NSString*) userAgent {
  return [_proxy valueForKey:@"USER_AGENT"];
}

- (void) setJavaScript:(BOOL) val {
  [_proxy setValue:[NSNumber numberWithBool:val] forKey:@"JAVASCRIPT"];
}

- (BOOL) javaScript {
  return [[_proxy valueForKey:@"JAVASCRIPT"] boolValue];
}

- (void) setMediaPlayback:(BOOL) val {
  [_proxy setValue:[NSNumber numberWithBool:val] forKey:@"MEDIA_PLAYBACK"];
}

- (BOOL) mediaPlayback {
  return [[_proxy valueForKey:@"MEDIA_PLAYBACK"] boolValue];
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

  if (apol == 2) {
    webkit_settings_set_hardware_acceleration_policy(settings, WEBKIT_HARDWARE_ACCELERATION_POLICY_ON_DEMAND);
    webkit_settings_set_enable_accelerated_2d_canvas(settings, 1);
  }
  else if (apol == 1) {
    webkit_settings_set_hardware_acceleration_policy(settings, WEBKIT_HARDWARE_ACCELERATION_POLICY_ALWAYS);
    webkit_settings_set_enable_accelerated_2d_canvas(settings, 1);
  }
  else {
    webkit_settings_set_hardware_acceleration_policy(settings, WEBKIT_HARDWARE_ACCELERATION_POLICY_NEVER);
    webkit_settings_set_enable_accelerated_2d_canvas(settings, 0);
  }

  if ([[self userAgent] length] > 0) {
    webkit_settings_set_user_agent(settings, [[self userAgent] cString]);
  }
    
  webkit_settings_set_enable_developer_extras(settings, [self developerExtras]);
  webkit_settings_set_enable_javascript(settings, [self javaScript]);

  /*
   * these two functions are not available in Fedora out of the box
   * we don't need them anyways (yet)
  webkit_settings_set_enable_media(settings, [self mediaPlayback]);
  webkit_settings_set_enable_webaudio(settings, [self mediaPlayback]);
  */

  webkit_settings_set_enable_site_specific_quirks(settings, 1);
  webkit_settings_set_enable_webgl(settings, 0);  
  webkit_settings_set_enable_java(settings, 0);
  webkit_settings_set_enable_plugins(settings, 0);
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
