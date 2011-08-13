//
//  PTPusher.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTPusherDelegate.h"
#import "PTPusherConnection.h"

extern NSString *const PTPusherDataKey;
extern NSString *const PTPusherEventKey;
extern NSString *const PTPusherEventReceivedNotification;

@interface PTPusher : NSObject <PTPusherConnectionDelegate> {
  NSMutableDictionary *eventListeners;
}
@property (nonatomic, assign) id<PTPusherDelegate> delegate;
@property (nonatomic, assign, getter=shouldReconnectAutomatically) BOOL reconnectAutomatically;
@property (nonatomic, assign) NSTimeInterval reconnectDelay;
@property (nonatomic, readonly, getter=isConnected) BOOL connected;

- (id)initWithConnection:(PTPusherConnection *)connection connectAutomatically:(BOOL)connectAutomatically;
- (void)addEventListener:(NSString *)event target:(id)target selector:(SEL)selector;
@end

@class PTPusherChannel;

@interface PTPusher (SharedFactory)
+ (void)setKey:(NSString *)apiKey;
+ (void)setSecret:(NSString *)secret;
+ (void)setAppID:(NSString *)appId;
+ (PTPusherChannel *)channel:(NSString *)name;
+ (PTPusherChannel *)newChannel:(NSString *)name;
@end

