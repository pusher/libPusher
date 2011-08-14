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

@protocol PTPusherDelegate <NSObject>

@optional
- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection;
- (void)pusher:(PTPusher *)pusher connectionDidDisconnect:(PTPusherConnection *)connection;
- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error;
- (void)pusher:(PTPusher *)pusher connectionWillReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay;
- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel;
- (void)pusher:(PTPusher *)pusher didUnsubscribeFromChannel:(PTPusherChannel *)channel;
- (void)pusher:(PTPusher *)pusher didFailToSubscribeToChannel:(PTPusherChannel *)channel withError:(NSError *)error;
@end
