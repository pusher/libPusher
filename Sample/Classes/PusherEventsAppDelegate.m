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
#import "PTPusherChannel.h"
#import "NSMutableURLRequest+BasicAuth.h"
#import "Reachability.h"

// All events will be logged
#define kLOG_ALL_EVENTS

// change this to switch between secure/non-secure connections
#define kUSE_ENCRYPTED_CHANNELS NO

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
  connectedClients = [[NSMutableArray alloc] init];
  clientsAwaitingConnection = [[NSMutableArray alloc] init];
  
  // create our primary Pusher client instance
  self.pusher = [self createClientWithAutomaticConnection:YES];
  
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
  [connectedClients release];
  [menuViewController release];
  [navigationController release];
  [window release];
  [super dealloc];
}

#pragma mark - Event notifications

- (void)handlePusherEvent:(NSNotification *)note
{
#ifdef kLOG_ALL_EVENTS
  PTPusherEvent *event = [note.userInfo objectForKey:PTPusherEventUserInfoKey];
  NSLog(@"[pusher] Received event %@", event);
#endif
}

#pragma mark - Client management

- (PTPusher *)lastConnectedClient
{
  return [connectedClients lastObject];
}

- (PTPusher *)createClientWithAutomaticConnection:(BOOL)connectAutomatically
{
  PTPusher *client = [PTPusher pusherWithKey:PUSHER_API_KEY connectAutomatically:YES encrypted:kUSE_ENCRYPTED_CHANNELS];
  client.delegate = self;
  [clientsAwaitingConnection addObject:client];
  return client;
}

#pragma mark - PTPusherDelegate methods

- (void)handlePusherConnectionFailure
{
  Reachability *reachability = [Reachability reachabilityForInternetConnection];
  
  if ([reachability isReachable]) {
    NSLog(@"Connection available, possible Pusher server issue. Waiting before retrying.");
    
    // this might have been a temporary issue, so let's try again in after a short delay
    double delayInSeconds = 10.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
      [self.pusher connect];
    });
  }
  else {
    NSLog(@"Connection unavailable, waiting before re-attempting to connect to Pusher.");
    
    // we'll have to wait until we're back online
    [[NSNotificationCenter defaultCenter] 
     addObserver:self 
     selector:@selector(reachabilityForPusherChanged:) 
     name:kReachabilityChangedNotification object:reachability];
    
    [reachability startNotifier];
    
  }
}

- (void)reachabilityForPusherChanged:(NSNotification *)note
{
  Reachability *reachability = note.object;
  
  if ([reachability isReachable]) {
    NSLog(@"Connection re-established, re-connecting to Pusher.");
    // once we've re-established a connection, we can try an connect to Pusher again
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:reachability];
    [reachability stopNotifier];
    [self.pusher connect];
  }
}

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
  NSLog(@"[pusher-%@] Connected to Pusher (socket id: %@)", pusher.connection.socketID, connection.socketID);
  [connectedClients addObject:pusher];
  [clientsAwaitingConnection removeObject:pusher];
  
  pusher.reconnectAutomatically = YES;
  
  Reachability *reachability = [Reachability reachabilityForInternetConnection];
  
  if ([reachability isReachableViaWiFi]) {
    pusher.reconnectDelay = 3.0;
  }
  else {
    pusher.reconnectDelay = 15.0;
  }
}

- (void)pusher:(PTPusher *)pusher connectionDidDisconnect:(PTPusherConnection *)connection
{
  NSLog(@"[pusher-%@] Disconnected from Pusher", pusher.connection.socketID);
  [connectedClients removeObject:pusher];
  
  if (pusher == self.pusher) {
    self.pusher.reconnectAutomatically = NO;
    [self handlePusherConnectionFailure];
  }
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
  NSLog(@"[pusher-%@] Failed to connect to pusher, error: %@", pusher.connection.socketID, error);
  [clientsAwaitingConnection removeObject:pusher];
  
  if (pusher == self.pusher) {
    [self handlePusherConnectionFailure];
  }
}

- (void)pusher:(PTPusher *)pusher connectionWillReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay
{
  NSLog(@"[pusher-%@] Reconnecting after %d seconds...", pusher.connection.socketID, (int)delay);
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
  [alert autorelease];
  
  if (pusher != self.pusher) {
    [pusher disconnect];
  }
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
