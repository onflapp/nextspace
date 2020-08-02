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

- (GtkWidget*) createWidget
{        
    //GtkWidget* btn = gtk_button_new_with_label("hello");
    //return btn;
    webView = WEBKIT_WEB_VIEW(webkit_web_view_new());
    return webView;
}

- (void) loadURL:(NSURL*) url {
  if (!url) return;
 
  webkit_web_view_load_uri(webView, [[url description] cString]);
}

- (void) copy:(id)sender {
  webkit_web_view_execute_editing_command(webView, WEBKIT_EDITING_COMMAND_COPY);
  [self processPendingEvents];
  
  GtkClipboard* clip = gtk_clipboard_get(GDK_SELECTION_CLIPBOARD);
  gchar* text = gtk_clipboard_wait_for_text(clip);
  
  if (text) {
    NSString* val = [NSString stringWithUTF8String:text];
    
    NSPasteboard* pboard = [NSPasteboard generalPasteboard];
    [pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [pboard setString:val forType: NSStringPboardType];
  }
}

- (void) cut:(id)sender {
  webkit_web_view_execute_editing_command(webView, WEBKIT_EDITING_COMMAND_CUT);
  [self processPendingEvents];
  
  GtkClipboard* clip = gtk_clipboard_get(GDK_SELECTION_CLIPBOARD);
  gchar* text = gtk_clipboard_wait_for_text(clip);
  
  if (text) {
    NSPasteboard* pboard = [NSPasteboard generalPasteboard];
    [pboard declareTypes:[NSArray arrayWithObject: NSStringPboardType] owner:nil];
    [pboard setString:[NSString stringWithUTF8String:text] forType:NSStringPboardType];
  }
}

- (void) paste:(id)sender {
  NSPasteboard* pboard = [NSPasteboard generalPasteboard];
  NSString* str = [pboard stringForType:NSStringPboardType];
  
  if (str) {
    GtkClipboard* clip = gtk_clipboard_get(GDK_SELECTION_CLIPBOARD);
    gchar* text = [str UTF8String];
    gtk_clipboard_set_text(clip, text, strlen(text));
    
    webkit_web_view_execute_editing_command(webView, WEBKIT_EDITING_COMMAND_PASTE);
    [self processPendingEvents];
  }
}

- (void) selectAll:(id)sender {
  webkit_web_view_execute_editing_command(webView, WEBKIT_EDITING_COMMAND_SELECT_ALL);
  [self processPendingEvents];
}

- (void) undo:(id)sender {
  webkit_web_view_execute_editing_command(webView, WEBKIT_EDITING_COMMAND_UNDO);
  [self processPendingEvents];
}

- (void) redo:(id)sender {
  webkit_web_view_execute_editing_command(webView, WEBKIT_EDITING_COMMAND_REDO);
  [self processPendingEvents];
}

- (void) stopLoading:(id) sender {
  webkit_web_view_stop_loading(webView);
  [self processPendingEvents];
}

- (void) goBack:(id) sender {
  webkit_web_view_go_back(webView);
  [self processPendingEvents];
}

- (void) goForward:(id) sender {
  webkit_web_view_go_forward(webView);
  [self processPendingEvents];
}

@end
