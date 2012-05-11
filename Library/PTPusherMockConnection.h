//
//  PTPusherMockConnection.h
//  libPusher
//
//  Created by Luke Redpath on 11/05/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTPusherConnection.h"

@interface PTPusherMockConnection : PTPusherConnection

@property (nonatomic, readonly, getter=isConnected) BOOL connected;

- (void)simulateServerEventNamed:(NSString *)name data:(id)data channel:(NSString *)channelName;
- (void)simulateServerEventNamed:(NSString *)name data:(id)data;

@end
