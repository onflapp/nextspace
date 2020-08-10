#ifndef _PCAPPPROJ_WEBVIEW_H
#define _PCAPPPROJ_WEBVIEW_H

#import <AppKit/AppKit.h>
#import "GTKWidgetView.h"

@interface GTKWebView : GTKWidgetView {
  IBOutlet id delegate;
}

- (void) setDelegate:(id) del;
- (id) delegate;

- (void) loadURL:(NSURL*) url;

- (void) stopLoading:(id) sender;
- (void) goBack:(id) sender;
- (void) goForward:(id) sender;

@end

#endif