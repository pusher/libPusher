//
//  PusherEventsAppDelegate.m
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright LJR Software Limited 2010. All rights reserved.
//

#import "PusherEventsAppDelegate.h"
#import "PusherExampleMenuViewController.h"
#import "Pusher.h"
#import "NSMutableURLRequest+BasicAuth.h"
#import "Reachability.h"
#import "PTPusher+ReactiveExtensions.h"

// All events will be logged
#define kLOG_ALL_EVENTS

// change this to switch between secure/non-secure connections
#define kUSE_ENCRYPTED_CHANNELS NO

// this is not included in the source
// you must create this yourself and define PUSHER_API_KEY in it
#import "Constants.h" 

@implementation PusherEventsAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
  self.pusherClient = [PTPusher pusherWithKey:PUSHER_API_KEY delegate:self encrypted:YES];
  
  // log all events received, regardless of which channel they come from
  [[self.pusherClient allEvents] subscribeNext:^(PTPusherEvent *event) {
    NSLog(@"[pusher] Received event %@", event);
  }];
  
  self.menuViewController.pusher = self.pusherClient;
  self.window.rootViewController = self.navigationController;
  
  [self.window makeKeyAndVisible];
  
  [self.pusherClient connect];
}

#pragma mark - Reachability

- (void)startReachabilityCheck
{
  // we probably have no internet connection, so lets check with Reachability
  Reachability *reachability = [Reachability reachabilityWithHostname:self.pusherClient.connection.URL.host];
  
  if ([reachability isReachable]) {
    // we appear to have a connection, so something else must have gone wrong
    NSLog(@"Internet reachable, reconnecting");
    [_pusherClient connect];
  }
  else {
    NSLog(@"Waiting for reachability");
    
    [reachability setReachableBlock:^(Reachability *reachability) {
      if ([reachability isReachable]) {
        NSLog(@"Internet is now reachable");
        [reachability stopNotifier];
        
        dispatch_async(dispatch_get_main_queue(), ^{
          [self.pusherClient connect];
        });
      }
    }];
    
    [reachability startNotifier];
  }
}

#pragma mark - PTPusherDelegate methods

- (BOOL)pusher:(PTPusher *)pusher connectionWillConnect:(PTPusherConnection *)connection
{
  NSLog(@"[pusher] Pusher client connecting...");
  return YES;
}

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
  NSLog(@"[pusher-%@] Pusher client connected", connection.socketID);
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
  NSLog(@"[pusher] Pusher Connection failed with error: %@", error);
  if ([error.domain isEqualToString:(NSString *)kCFErrorDomainCFNetwork]) {
    [self startReachabilityCheck];
  }
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error willAttemptReconnect:(BOOL)willAttemptReconnect
{
  NSLog(@"[pusher-%@] Pusher Connection disconnected with error: %@", pusher.connection.socketID, error);
  
  if (willAttemptReconnect) {
    NSLog(@"[pusher-%@] Client will attempt to reconnect automatically", pusher.connection.socketID);
  }
  else {
    if (error && ![error.domain isEqualToString:PTPusherErrorDomain]) {
      [self startReachabilityCheck];
    }
  }
}

- (BOOL)pusher:(PTPusher *)pusher connectionWillAutomaticallyReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay
{
  NSLog(@"[pusher-%@] Client automatically reconnecting after %d seconds...", pusher.connection.socketID, (int)delay);
  return YES;
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel
{
  NSLog(@"[pusher-%@] Subscribed to channel %@", pusher.connection.socketID, channel);
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error
{
  NSLog(@"[pusher-%@] Authorization failed for channel %@", pusher.connection.socketID, channel);
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authorization Failed" message:[NSString stringWithFormat:@"Client with socket ID %@ could not be authorized to join channel %@", pusher.connection.socketID, channel.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alert show];
}

- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent
{
  NSLog(@"[pusher-%@] Received error event %@", pusher.connection.socketID, errorEvent);
}

/* The sample app uses HTTP basic authentication.
 
   This demonstrates how we can intercept the authorization request to configure it for our app's
   authentication/authorisation needs.
 */
- (void)pusher:(PTPusher *)pusher willAuthorizeChannelWithRequest:(NSMutableURLRequest *)request
{
  NSLog(@"[pusher-%@] Authorizing channel access...", pusher.connection.socketID);
  [request setHTTPBasicAuthUsername:CHANNEL_AUTH_USERNAME password:CHANNEL_AUTH_PASSWORD];
}

@end
