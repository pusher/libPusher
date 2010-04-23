//
//  PTPusherChannelDelegate.h
//  libPusher
//
//  Created by Luke Redpath on 23/04/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PTPusherChannel;
@class PTPusherEvent;

@protocol PTPusherChannelDelegate <NSObject>

@optional
- (void)channelDidConnect:(PTPusherChannel *)channel;
- (void)channelDidDisconnect:(PTPusherChannel *)channel;
- (void)channel:(PTPusherChannel *)channel didReceiveEvent:(PTPusherEvent *)event;
- (void)channelDidTriggerEvent:(PTPusherChannel *)channel;
- (void)channelFailedToTriggerEvent:(PTPusherChannel *)channel error:(NSError *)error;

@end
