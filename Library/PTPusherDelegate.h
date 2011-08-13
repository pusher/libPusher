//
//  PTPusherDelegate.h
//  libPusher
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

@class PTPusher;
@class PTPusherConnection;

@protocol PTPusherDelegate <NSObject>

@optional
- (void)pusher:(PTPusher *)pusher connectionDidConnect:(PTPusherConnection *)connection;
- (void)pusher:(PTPusher *)pusher connectionDidDisconnect:(PTPusherConnection *)connection;
- (void)pusher:(PTPusher *)pusher connection:(PTPusherConnection *)connection failedWithError:(NSError *)error;
- (void)pusher:(PTPusher *)pusher connectionWillReconnect:(PTPusherConnection *)connection afterDelay:(NSTimeInterval)delay;
@end
