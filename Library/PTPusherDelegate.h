//
//  PTPusherDelegate.h
//  libPusher
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

@class PTPusher;
@class PTPusherConnection;
@class PTPusherChannel;

/** The PTPusherDelegate protocol can be implemented to receive important events in a PTPusher object's lifetime.
 
 All of the delegate methods are optional; you only need to implement what is required for your app.
 
 It may be useful to assign a delegate to monitor the status of the connection; you could use this to update
 your user interface accordingly.
 */
@protocol PTPusherDelegate <NSObject>

@optional

/** Notifies the delegate that the PTPusher instance has connected to the Pusher service successfully.
 
 @param pusher The PTPusher instance that has connected.
 @param connection The connection for the pusher instance.
 */
- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection;

/** Notifies the delegate that the PTPusher instance has disconnected from the Pusher service.
 
 @param pusher The PTPusher instance that has connected.
 @param connection The connection for the pusher instance.
 */
- (void)pusher:(PTPusher *)pusher connectionDidDisconnect:(PTPusherConnection *)connection;

/** Notifies the delegate that the PTPusher instance failed to connect to the Pusher service.
 
 @param pusher The PTPusher instance that has connected.
 @param connection The connection for the pusher instance.
 @param error The connection error.
 */
- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error;

/** Notifies the delegate that the PTPusher instance is about to attempt reconnection.
 
 You may wish to use this method to keep track of the number of reconnection attempts and abort after a fixed number.
 
 If you do not set the `reconnectAutomatically` property of the PTPusher instance to NO, it will continue attempting
 to reconnect until a successful connection has been established.
 
 @param pusher The PTPusher instance that has connected.
 @param connection The connection for the pusher instance.
 */
- (void)pusher:(PTPusher *)pusher connectionWillReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay;

/** Notifies the delegate that the PTPusher instance has subscribed to the specified channel.
 
 This method will be called after any channel authorization has taken place and when a subscribe event has been received.
 
 @param pusher The PTPusher instance that has connected.
 @param channel The channel that was subscribed to.
 */
- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel;

/** Notifies the delegate that the PTPusher instance has unsubscribed from the specified channel.
 
 This method will be called immediately after unsubscribing from a channel.
 
 @param pusher The PTPusher instance that has connected.
 @param channel The channel that was unsubscribed from.
 */
- (void)pusher:(PTPusher *)pusher didUnsubscribeFromChannel:(PTPusherChannel *)channel;

/** Notifies the delegate that the PTPusher instance failed to subscribe to the specified channel.
 
 The most common reason for subscribing failing is authorization failing for private/presence channels.
 
 @param pusher The PTPusher instance that has connected.
 @param channel The channel that was subscribed to.
 @param error The error returned when attempting to subscribe.
 */
- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error;
@end
