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
 
  NSLog(@"[%@", url);
  webkit_web_view_load_uri(webView, [[url description] cString]);
}

- (void) copy:(id)sender {
  webkit_web_view_execute_editing_command(webView, WEBKIT_EDITING_COMMAND_COPY);

  [self processPendingEvents];
  
  GtkClipboard* clip = gtk_clipboard_get(GDK_SELECTION_CLIPBOARD);
  gchar* text = gtk_clipboard_wait_for_text(clip);
  
  if (text) {
    NSPasteboard* pboard = [NSPasteboard generalPasteboard];
    [pboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:nil];
    [pboard setString:[NSString stringWithUTF8String:text] forType:NSPasteboardTypeString];
  }
}

- (void) cut:(id)sender {
  GtkClipboard* clip = gtk_clipboard_get(GDK_SELECTION_CLIPBOARD);
  webkit_web_view_execute_editing_command(webView, WEBKIT_EDITING_COMMAND_CUT);

  gchar* text = gtk_clipboard_wait_for_text(clip);
  
  if (text) {
    NSPasteboard* pboard = [NSPasteboard generalPasteboard];
    [pboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:nil];
    [pboard setString:[NSString stringWithUTF8String:text] forType:NSPasteboardTypeString];
  }
}

- (void) paste:(id)sender {

  NSPasteboard* pboard = [NSPasteboard generalPasteboard];
  NSString* str = [pboard stringForType:NSPasteboardTypeString];
  if (str) {
    GtkClipboard* clip = gtk_clipboard_get(GDK_SELECTION_CLIPBOARD);
    gchar* text = [str UTF8String];
    gtk_clipboard_set_text(clip, text, strlen(text));
    webkit_web_view_execute_editing_command(webView, WEBKIT_EDITING_COMMAND_PASTE);
  }
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

@end
