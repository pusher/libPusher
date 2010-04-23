//
//  PTPusherDelegate.h
//  libPusher
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

@class PTPusher;

@protocol PTPusherDelegate <NSObject>

@optional
- (void)pusherWillConnect:(PTPusher *)pusher;
- (void)pusherDidConnect:(PTPusher *)pusher;
- (void)pusherDidDisconnect:(PTPusher *)pusher;
- (void)pusherDidFailToConnect:(PTPusher *)pusher withError:(NSError *)error;
- (void)pusherWillReconnect:(PTPusher *)pusher afterDelay:(NSUInteger)delay;
@end
