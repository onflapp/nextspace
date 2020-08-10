#import "GTKWebView.h"
#import "GTKWidgetView.h"

#include <gtk/gtk.h>
#include <webkit2/webkit2.h>

@interface GTKWebView ()
{
  WebKitWebView* webView;
}
@end

@implementation GTKWebView

- (id) initWithFrame:(NSRect)r {
  self = [super initWithFrame:r];  
  return self;
}

- (GtkWidget*) createWidget {
  NSLog(@"createWidget");
  
  webView = WEBKIT_WEB_VIEW(webkit_web_view_new());
  webkit_web_view_load_uri(webView, "https://www.x.org");
  
  return webView;
}

- (void) loadURL:(NSURL*) url {
  if (!url) return;
 
  [self executeInGTK:^{
    webkit_web_view_load_uri(webView, [[url description] cString]);
  }];
}

- (void) copy:(id)sender {
  [self executeInGTK:^{
    webkit_web_view_execute_editing_command(webView, WEBKIT_EDITING_COMMAND_COPY);
  }];
}

- (void) cut:(id)sender {
  webkit_web_view_execute_editing_command(webView, WEBKIT_EDITING_COMMAND_CUT);
}

- (void) paste:(id)sender {
  webkit_web_view_execute_editing_command(webView, WEBKIT_EDITING_COMMAND_PASTE);
}

- (void) selectAll:(id)sender {
  webkit_web_view_execute_editing_command(webView, WEBKIT_EDITING_COMMAND_SELECT_ALL);
}

- (void) undo:(id)sender {
  webkit_web_view_execute_editing_command(webView, WEBKIT_EDITING_COMMAND_UNDO);
}

- (void) redo:(id)sender {
  webkit_web_view_execute_editing_command(webView, WEBKIT_EDITING_COMMAND_REDO);
}

- (void) stopLoading:(id) sender {
  webkit_web_view_stop_loading(webView);
}

- (void) goBack:(id) sender {
  [self executeInGTK:^{
    webkit_web_view_go_back(webView);
  }];
}

- (void) goForward:(id) sender {
  [self executeInGTK:^{
    webkit_web_view_go_forward(webView);
  }];
}

@end
