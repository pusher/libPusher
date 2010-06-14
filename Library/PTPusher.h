//
//  PTPusher.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZTWebSocket.h"
#import "PTPusherDelegate.h"

extern NSString *const PTPusherDataKey;
extern NSString *const PTPusherEventKey;
extern NSString *const PTPusherEventReceivedNotification;

@interface PTPusher : NSObject <ZTWebSocketDelegate> {
  NSString *APIKey;
  NSString *channel;
  NSString *host;
  NSUInteger port;
  NSMutableDictionary *eventListeners;
  ZTWebSocket *socket;
  NSUInteger socketID;
  id<PTPusherDelegate> delegate;
  BOOL reconnect;
}
@property (nonatomic, readonly) NSString *APIKey;
@property (nonatomic, readonly) NSString *channel;
@property (nonatomic, readonly) NSUInteger socketID;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) NSUInteger port;
@property (nonatomic, assign) id<PTPusherDelegate> delegate;
@property (nonatomic, assign) BOOL reconnect;

- (id)initWithKey:(NSString *)key channel:(NSString *)channelName;
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

