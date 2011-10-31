//
//  PusherEventsAppDelegate.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import "PusherEventsAppDelegate.h"
#import "PusherExampleMenuViewController.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "NSMutableURLRequest+BasicAuth.h"

// change this to switch between secure/non-secure connections
#define kUSE_ENCRYPTED_CHANNELS YES

// this is not included in the source
// you must create this yourself and define PUSHER_API_KEY in it
#import "Constants.h" 

@implementation PusherEventsAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize menuViewController;
@synthesize pusher = _pusher;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{    
  // establish a new pusher instance
  self.pusher = [PTPusher pusherWithKey:PUSHER_API_KEY delegate:self encrypted:kUSE_ENCRYPTED_CHANNELS];
  
  // we want the connection to automatically reconnect if it dies
  self.pusher.reconnectAutomatically = YES;
  
  // log all events received, regardless of which channel they come from
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePusherEvent:) name:PTPusherEventReceivedNotification object:self.pusher];
  
  // pass the pusher into the events controller
  self.menuViewController.pusher = self.pusher;
  
  [window addSubview:navigationController.view];
  [window makeKeyAndVisible];
}

- (void)dealloc 
{
  [[NSNotificationCenter defaultCenter] 
    removeObserver:self name:PTPusherEventReceivedNotification object:self.pusher];
  [_pusher release];
  [menuViewController release];
  [navigationController release];
  [window release];
  [super dealloc];
}

#pragma mark - Event notifications

- (void)handlePusherEvent:(NSNotification *)note
{
  PTPusherEvent *event = [note.userInfo objectForKey:PTPusherEventUserInfoKey];
  NSLog(@"[pusher] Received event %@", event);
}

#pragma mark - PTPusherDelegate methods

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
  NSLog(@"[pusher-%@] Connected to Pusher (socket id: %@)", pusher.connection.socketID, connection.socketID);
}

- (void)pusher:(PTPusher *)pusher connectionDidDisconnect:(PTPusherConnection *)connection
{
  NSLog(@"[pusher-%@] Disconnected from Pusher", pusher.connection.socketID);
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
  NSLog(@"[pusher-%@] Failed to connect to pusher, error: %@", pusher.connection.socketID, error);
}

- (void)pusher:(PTPusher *)pusher connectionWillReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay
{
  NSLog(@"[pusher-%@] Reconnecting after %d seconds...", pusher.connection.socketID, (int)delay);
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error
{
  NSLog(@"[pusher-%@] Authorization failed for channel %@", pusher.connection.socketID, channel);
}

/* The sample app uses HTTP basic authentication.
 
   This demonstrates how we can intercept the authorization request to configure it for our app's
   authentication/authorisation needs.
 */
- (void)pusher:(PTPusher *)pusher willAuthorizeChannelWithRequest:(NSMutableURLRequest *)request
{
  [request setHTTPBasicAuthUsername:CHANNEL_AUTH_USERNAME password:CHANNEL_AUTH_PASSWORD];
}

@end
