//
//  PusherEventsAppDelegate.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import "PusherEventsAppDelegate.h"
#import "PusherEventsViewController.h"
#import "PTPusher.h"

@implementation PusherEventsAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize pusher;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    
  pusher = [[PTPusher alloc] initWithKey:@"MY_API_KEY" channel:@"demo"];

  [window addSubview:viewController.view];
  [window makeKeyAndVisible];
}

- (void)dealloc 
{
  [pusher release];
  [viewController release];
  [window release];
  [super dealloc];
}

@end
