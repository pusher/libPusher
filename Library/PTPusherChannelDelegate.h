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
// Regular Channels
- (void)channel:(PTPusherChannel *)channel didReceiveEvent:(PTPusherEvent *)event;
- (void)channelDidTriggerEvent:(PTPusherChannel *)channel;
- (void)channelFailedToTriggerEvent:(PTPusherChannel *)channel error:(NSError *)error;

// Both Private and Presence
- (NSDictionary *)extraParamsForChannelAuthentication:(PTPusherChannel *)channel;
- (BOOL)channel:(PTPusherChannel *)channel continueSubscriptionWithAuthResponse:(NSData *)data;

- (void)channelAuthenticationStarted:(PTPusherChannel *)channel;
- (void)channelAuthenticationFailed:(PTPusherChannel *)channel withError:(NSError *)error;

// Presence Channels
- (void)presenceChannelSubscriptionSucceeded:(PTPusherChannel *)channel withUserInfo:(NSArray *)userList;
- (void)presenceChannel:(PTPusherChannel *)channel memberAdded:(NSDictionary *)memberInfo;
- (void)presenceChannel:(PTPusherChannel *)channel memberRemoved:(NSDictionary *)memberInfo;

@end
