//
//  PTPusherPresenceChannelDelegate.h
//  libPusher
//
//  Created by Juan Alvarez on 1/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PTPusherPresenseChannel;

@protocol PTPusherPresenceChannelDelegate <NSObject>

@optional
- (void)presenceChannelSubscriptionSucceeded:(PTPusherPresenseChannel *)channel withUserInfo:(NSDictionary *)userInfo;
- (void)presenceChannel:(PTPusherPresenseChannel *)channel memberAdded:(NSDictionary *)memberInfo;
- (void)presenceChannel:(PTPusherPresenseChannel *)channel memberRemoved:(NSDictionary *)memberInfo;

@end