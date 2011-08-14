//
//  PTPusherPresenceChannelDelegate.h
//  libPusher
//
//  Created by Luke Redpath on 14/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PTPusherPresenceChannel;

@protocol PTPusherPresenceChannelDelegate <NSObject>

- (void)presenceChannel:(PTPusherPresenceChannel *)channel didSubscribeWithMemberList:(NSArray *)members;
- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberAdded:(NSDictionary *)memberData;
- (void)presenceChannel:(PTPusherPresenceChannel *)channel memberRemoved:(NSDictionary *)memberData;

@end
