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
  
  [pusher addEventListener:@"connection_established" target:self selector:@selector(pusherConnected:)];
  [pusher addEventListener:@"alert" target:self selector:@selector(handleAlertEvent:)];
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

#pragma mark -
#pragma mark Sample Pusher event handlers

- (void)pusherConnected:(id)data;
{
  NSLog(@"Pusher connected with socket id %d", pusher.socketID);
}

- (void)handleAlertEvent:(PTPusherEvent *)event;
{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[event.data valueForKey:@"title"] message:[event.data valueForKey:@"message"] delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
  [alertView show];
  [alertView release];
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
