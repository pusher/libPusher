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
#import "PTPusherEvent.h"
#import "Constants.h"

@implementation PusherEventsAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize pusher;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    
  pusher = [[PTPusher alloc] initWithKey:PUSHER_API_KEY channel:@"test_channel"];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePusherEvent:) name:PTPusherEventReceivedNotification object:nil];
  
  [pusher addEventListener:@"alert" target:self selector:@selector(handleAlertEvent:)];
  [window addSubview:viewController.view];
  [window makeKeyAndVisible];
}

- (void)dealloc 
{
  [[NSNotificationCenter defaultCenter] 
    removeObserver:self name:PTPusherEventReceivedNotification object:pusher];
  [pusher release];
  [viewController release];
  [window release];
  [super dealloc];
}

#pragma mark -
#pragma mark Sample Pusher event handlers

// specific alert handler, handle events using target/selector dispatch
- (void)handleAlertEvent:(PTPusherEvent *)event;
{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[event.data valueForKey:@"title"] message:[event.data valueForKey:@"message"] delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
  [alertView show];
  [alertView release];
}

// generic alert handler, handle all events using NSNotifications
- (void)handlePusherEvent:(NSNotification *)note;
{
  NSLog(@"Received event: %@", note.object);
}

#pragma mark -
#pragma mark UIAlertView delegate methods

- (void)didPresentAlertView:(UIAlertView *)alertView
{
  [self performSelector:@selector(dismissAlertView:) withObject:alertView afterDelay:1];
}

- (void)dismissAlertView:(UIAlertView *)alertView;
{
  [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

@end
