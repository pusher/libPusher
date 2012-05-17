//
//  PTPusherConnectionMonitor.m
//  libPusher
//
//  Created by Luke Redpath on 26/01/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import <objc/runtime.h>
#import "PTPusherConnectionMonitor.h"
#import "Reachability.h"
#import "PTPusher.h"

#define kPTOriginalClientDelegateRefKey @"kPTOriginalClientDelegateRefKey"
#define kPTClientReachabilityRefKey     @"kPTClientReachabilityRefKey"

@interface PTPusherConnectionMonitor ()
- (id<PTPusherDelegate>)originalDelegateFor:(PTPusher *)pusher;
- (Reachability *)reachabilityForClient:(PTPusher *)client;
- (void)handlePusherConnectionFailure:(PTPusher *)pusher;
@end

@implementation PTPusherConnectionMonitor {
  NSMutableSet *monitoredClients;
  BOOL isConnected;
}

- (id)init 
{
  if ((self = [super init])) {
    monitoredClients = [[NSMutableSet alloc] init];
  }
  return self;
}

- (void)startMonitoringClient:(PTPusher *)client
{
  // create an association to the original delgate so it still works
  id<PTPusherDelegate> originalDelegate = client.delegate;
  
  if (originalDelegate && originalDelegate != self) {
    objc_setAssociatedObject(client, kPTOriginalClientDelegateRefKey, originalDelegate, OBJC_ASSOCIATION_ASSIGN);
  }
  
  // the monitor needs to be come the delegate so it can handle failures
  client.delegate = self;
  
  // set a reasonable auto-reconnect delay as default, in case of Pusher server problems
  client.reconnectAutomatically = YES;
  client.reconnectDelay = 5.0;
  
  // give each individual connection it's own reachability monitor
  Reachability *reachability = [Reachability reachabilityForInternetConnection];
  objc_setAssociatedObject(client, kPTClientReachabilityRefKey, reachability, OBJC_ASSOCIATION_RETAIN);

  [monitoredClients addObject:client];
}

- (void)stopMonitoringClient:(PTPusher *)client
{
  assert([monitoredClients containsObject:client]);
  
  // restore the original delegate again
  id<PTPusherDelegate> originalDelegate = objc_getAssociatedObject(client, kPTOriginalClientDelegateRefKey);
  client.delegate = originalDelegate;
  objc_setAssociatedObject(client, kPTOriginalClientDelegateRefKey, nil, OBJC_ASSOCIATION_ASSIGN);
  
  // remove the reachability monitor
  objc_setAssociatedObject(client, kPTClientReachabilityRefKey, nil, OBJC_ASSOCIATION_RETAIN);
  
  [monitoredClients removeObject:client];
}

- (id<PTPusherDelegate>)originalDelegateFor:(PTPusher *)pusher
{
  return objc_getAssociatedObject(pusher, kPTOriginalClientDelegateRefKey);
}

- (Reachability *)reachabilityForClient:(PTPusher *)client
{
  return objc_getAssociatedObject(client, kPTClientReachabilityRefKey);
}

#pragma mark - PTPusherDelegate methods

- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection
{
  isConnected = YES;
  
  pusher.reconnectAutomatically = YES;
  
  Reachability *reachability = [self reachabilityForClient:pusher];
 
  if ([reachability isReachableViaWiFi]) {
    pusher.reconnectDelay = 3.0;
  }
  else {
    pusher.reconnectDelay = 15.0;
  }
  
  if ([[self originalDelegateFor:pusher] respondsToSelector:@selector(pusher:connectionDidConnect:)]) {
    [[self originalDelegateFor:pusher] pusher:pusher connectionDidConnect:connection];
  }
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection didDisconnectWithError:(NSError *)error
{
  isConnected = NO;
  
  pusher.reconnectAutomatically = NO;
  
  if (error) {
    [self handlePusherConnectionFailure:pusher];
  }
  
  if ([[self originalDelegateFor:pusher] respondsToSelector:@selector(pusher:connection:didDisconnectWithError:)]) {
    [[self originalDelegateFor:pusher] pusher:pusher connection:connection didDisconnectWithError:error];
  }
}

- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error
{
  if (isConnected == NO) {
    [self handlePusherConnectionFailure:pusher];
  }
  
  isConnected = NO;
  
  if ([[self originalDelegateFor:pusher] respondsToSelector:@selector(pusher:connection:failedWithError:)]) {
    [[self originalDelegateFor:pusher] pusher:pusher connection:connection failedWithError:error];
  }
}

#pragma mark - Unused delegate methods (forwarding only)

- (void)pusher:(PTPusher *)pusher connectionWillReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay
{
  if ([[self originalDelegateFor:pusher] respondsToSelector:@selector(pusher:connectionWillReconnect:afterDelay:)]) {
    [[self originalDelegateFor:pusher] pusher:pusher connectionWillReconnect:connection afterDelay:delay];
  }
}

- (void)pusher:(PTPusher *)pusher willAuthorizeChannelWithRequest:(NSMutableURLRequest *)request
{
  if ([[self originalDelegateFor:pusher] respondsToSelector:@selector(pusher:willAuthorizeChannelWithRequest:)]) {
    [[self originalDelegateFor:pusher] pusher:pusher willAuthorizeChannelWithRequest:request];
  }
}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel
{
  if ([[self originalDelegateFor:pusher] respondsToSelector:@selector(pusher:didSubscribeToChannel:)]) {
    [[self originalDelegateFor:pusher] pusher:pusher didSubscribeToChannel:channel];
  }
}

- (void)pusher:(PTPusher *)pusher didUnsubscribeFromChannel:(PTPusherChannel *)channel
{
  if ([[self originalDelegateFor:pusher] respondsToSelector:@selector(pusher:didUnsubscribeFromChannel:)]) {
    [[self originalDelegateFor:pusher] pusher:pusher didUnsubscribeFromChannel:channel];
  }
}

- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error
{
  if ([[self originalDelegateFor:pusher] respondsToSelector:@selector(pusher:didFailToSubscribeToChannel:withError:)]) {
    [[self originalDelegateFor:pusher] pusher:pusher didFailToSubscribeToChannel:channel withError:error];
  }
}

- (void)pusher:(PTPusher *)pusher didReceiveErrorEvent:(PTPusherErrorEvent *)errorEvent
{
  if ([[self originalDelegateFor:pusher] respondsToSelector:@selector(pusher:didReceiveErrorEvent:)]) {
    [[self originalDelegateFor:pusher] pusher:pusher didReceiveErrorEvent:errorEvent];
  }
}

#pragma mark -

- (void)handlePusherConnectionFailure:(PTPusher *)pusher
{
  Reachability *reachability = [self reachabilityForClient:pusher];
  
  if ([reachability isReachable]) {
#ifdef DEBUG
    NSLog(@"Network reachable, possible Pusher server issue. Let auto-reconnect do it's job.");
#endif
  }
  else {
    NSLog(@"Network unreachable, waiting before re-attempting to connect to Pusher %@.", pusher);
    
    reachability.reachableBlock = ^(Reachability *r) {
#ifdef DEBUG
      NSLog(@"Network reachable, re-attempting to reconnect Pusher %@", pusher);
#endif
      dispatch_async(dispatch_get_main_queue(), ^{
        [pusher connect];
        [r stopNotifier];
      });
    };
    
    [reachability startNotifier];
  }
}

@end
