//
//  PTPusherConnectionMonitor.h
//  libPusher
//
//  Created by Luke Redpath on 26/01/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTPusherDelegate.h"

@class PTPusher;

/** A simple connection monitor class for multiple PTPusher instances.
 
 This utility class, whilst not part of the main library, is used to demonstrate
 how to monitor your Pusher connection and handle disconnections from the service.
 
 It encapsulates the ideas described in the Pusher README and follows Apple best
 practices with regards to how the Reachability class should be used.
 
 You are welcome to use this as-is or as a basis for a similar class in your own apps.
 
 Whilst most people will only ever open a single Pusher connection, a single instance
 of this class will support monitoring of multiple clients if needed.
 
 In short, the logic for handling connection errors is as follows:
 
    * No pre-flight checks are made with regards to the network availability. After adding
      the client to the monitor, you should just attempt to connect.
 
    * The monitor will assign itself as the delegate of the client and so will be notified of
      any disconnection or connection failure events.
 
    * If the client fails to connect at all, and the network is reachable, we assume there
      is an issue with the Pusher service, and fall back to using the automatic reconnect
      functionality with a sensible delay (currently 5 seconds).
 
    * If the client disconnects with an error (i.e. a non-clean 
      disconnection that resulted from anything other than a `disconnect` call, we check
      if the network is reachable.
 
    * If the network is reachable, it assumes that everything is OK on the client side and waits 
      for the Pusher client to reconnect automatically (see below).
 
    * If the network is not reachable, auto-reconnect is disabled and Reachability notifications
      will be turned on. Once the network becomes reachable again, notifications are disabled
      and a re-connect is attempted.
 
    * Once a successful connection has been established, the client will be configured to
      auto-reconnect (assuming the network is good). The reconnect delay will be set to a lower
      value for WiFI connections and a higher value for 3G connections.
 
  Although the monitor sets itself as the client's delegate, it keeps a reference to any 
  original delegate you may have set and will forward all delegate messages on to the original
  delegate if it responds to them.
 */
@interface PTPusherConnectionMonitor : NSObject <PTPusherDelegate>

/** Adds a new client to be monitored. It will get it's own unique Reachability instance.
 
 The client's delegate will be changed to the connection monitor instance, but any original delegate
 will have it's messages forwarded.
 */
- (void)startMonitoringClient:(PTPusher *)client;

/** Removes a client to be monitored.
 
 The reachability instance will be removed and the original delegate restored.
 */
- (void)stopMonitoringClient:(PTPusher *)client;
@end
