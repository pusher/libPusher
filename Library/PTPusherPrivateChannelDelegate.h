//
//  PTPusherPrivateChannelDelegate.h
//  libPusher
//
//  Created by Juan Alvarez on 1/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PTPusherPrivateChannel;

@protocol PTPusherPrivateChannelDelegate <NSObject>

@required
- (NSDictionary *)privateChannelParametersForAuthentication:(PTPusherPrivateChannel *)channel;

@optional
- (void)privateChannelAuthenticationStarted:(PTPusherPrivateChannel *)channel;
- (void)privateChannelAuthenticated:(PTPusherPrivateChannel *)channel;
- (void)privateChannelAuthenticationFailed:(PTPusherPrivateChannel *)channel withError:(NSError *)error;

@end