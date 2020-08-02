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

- (void) receivedEvent:(void*) data
     type:(RunLoopEventType)type
     extra:(void*)extra
     forMode:(NSString*)mode 
{
  //BOOL rv = gtk_main_iteration_do(FALSE);
}



- (void) applicationDidFinishLaunching: (NSNotification *)aNotif
{
// Uncomment if your application is Renaissance-based
//  [NSBundle loadGSMarkupNamed: @"Main" owner: self];
/*
NSRunLoop* loop = [NSRunLoop mainRunLoop];
  Display* dpy = (Display*)[GSCurrentServer() serverDevice];
  int xeq = XConnectionNumber(dpy);
  [loop addEvent:(void*)(gsaddr)xeq type:ET_RDESC watcher:self forMode:NSDefaultRunLoopMode];
  */
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
