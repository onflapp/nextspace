#import "GTKWebView.h"
#import "GTKWidgetView.h"

#include <gtk/gtk.h>
#include <webkit2/webkit2.h>

static void handle_view_load_changed (WebKitWebView  *web_view,
                                   WebKitLoadEvent load_event,
                                   gpointer        user_data)
{
    switch (load_event) {
    case WEBKIT_LOAD_STARTED:
        /* New load, we have now a provisional URI */
        //provisional_uri = webkit_web_view_get_uri (web_view);
        /* Here we could start a spinner or update the
         * location bar with the provisional URI */
        break;
    case WEBKIT_LOAD_REDIRECTED:
        //redirected_uri = webkit_web_view_get_uri (web_view);
        break;
    case WEBKIT_LOAD_COMMITTED:
        /* The load is being performed. Current URI is
         * the final one and it won't change unless a new
         * load is requested or a navigation within the
         * same page is performed */
        //gchar* uri = webkit_web_view_get_uri (web_view);
        break;
    case WEBKIT_LOAD_FINISHED:
        /* Load finished, we can now stop the spinner */
        break;
    }
}

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

- (void) setDelegate:(id) del {
  delegate = del;
}
  
- (id) delegate {
  return delegate;
}

- (GtkWidget*) createWidgetForGTK {
  NSLog(@"createWidget");
  
  webView = WEBKIT_WEB_VIEW(webkit_web_view_new());
  g_signal_connect(G_OBJECT(webView), "load-changed", G_CALLBACK(handle_view_load_changed), self);
  
  return webView;
}

- (void) loadURL:(NSURL*) url {
  if (!url) return;
 
  [self executeInGTK:^{
    webkit_web_view_load_uri(webView, [[url description] cString]);
  }];
}

- (id)validRequestorForSendType:(NSString *)st
                     returnType:(NSString *)rt 
{
  if ([st isEqual:NSStringPboardType])
    return self;
  else
    return nil;
}

- (BOOL)writeSelectionToPasteboard:(NSPasteboard *)pb
                             types:(NSArray *)types
{
  NSString *sel = @"TBD";

  if (sel) {
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pb setString:sel forType:NSStringPboardType];
    return YES;
  }
  else {
    return NO;
  }
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
