/* 
   Project: WebBrowser

   Author: root

   Created: 2020-07-22 12:15:43 +0300 by root
   
   Application Controller
*/

#import "AppController.h"

@implementation AppController

+ (void) initialize
{
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];

  /*
   * Register your app's defaults here by adding objects to the
   * dictionary, eg
   *
   * [defaults setObject:anObject forKey:keyForThatObject];
   *
   */
  
  [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id) init
{
  if ((self = [super init]))
    {
    }
  return self;
}

- (void) dealloc
{
  [super dealloc];
}

- (void) awakeFromNib
{
}

- (void) applicationDidFinishLaunching: (NSNotification *)aNotif
{

}

- (BOOL) applicationShouldTerminate: (id)sender
{
  return YES;
}

- (void) applicationWillTerminate: (NSNotification *)aNotif
{
}

- (BOOL) application: (NSApplication *)application
            openFile: (NSString *)fileName
{
  NSURL* url = nil;
  if ([fileName hasPrefix:@"http"] || [fileName hasPrefix:@"file"]) {
    url = [NSURL URLWithString:fileName];
  }
  else {
    url = [NSURL fileURLWithPath:fileName];
  }
  
  if (url) {
    Document* doc = [[Document alloc] init];
    [doc setURL:url];
  }
  
  return NO;
}

- (void) showPrefPanel: (id)sender
{
}

- (void) newDocument: (id)sender
{
  Document *doc = [[Document alloc] init];
}

@end
