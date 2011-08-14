//
//  PTPusherChannelDelegate.h
//  libPusher
//
//  Created by Luke Redpath on 14/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PTPusherChannelDelegate <NSObject>

@optional
- (void)pusherChannelWasSubscribedTo:(PTPusherChannel *)channel;
- (void)pusherChannelWasUnsubscribedFrom:(PTPusherChannel *)channel;
- (void)pusherChannel:(PTPusherChannel *)channel didFailToSubscribeWithError:(NSError *)error;
@end
