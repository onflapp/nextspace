#ifndef _PCAPPPROJ_WEBVIEW_H
#define _PCAPPPROJ_WEBVIEW_H

#import <AppKit/AppKit.h>
#import "GTKWidgetView.h"
#import "GTKWebViewSettings.h"

@protocol GTKWebViewDelegate

- (void) webView:(id)webView didStartLoading:(NSURL*) url;
- (void) webView:(id)webView didFinishLoading:(NSURL*) url;
- (void) webView:(id)webView didChangeTitle:(NSString*) title;

@end

@interface GTKWebView : GTKWidgetView {
  IBOutlet id delegate;
  GTKWebViewSettings* _settings;
}

- (void) setDelegate:(id) del;
- (id) delegate;

- (GTKWebViewSettings*) settings;
- (void) loadURL:(NSURL*) url;

- (void) stopLoading:(id) sender;
- (void) goBack:(id) sender;
- (void) goForward:(id) sender;

@end

#endif
