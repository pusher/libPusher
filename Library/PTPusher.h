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
#import "PTPusherChannelDelegate.h"

@class PTPusherChannel;

extern NSString *const PTPusherEventReceivedNotification;

@interface PTPusher : NSObject <ZTWebSocketDelegate> {
	NSString *APIKey;	
	NSString *host;
	NSUInteger port;
	
	ZTWebSocket *socket;
	NSString *socketID;
	id <PTPusherDelegate, PTPusherChannelDelegate> delegate;
	BOOL reconnect;
	
	NSMutableDictionary *eventListeners;
	NSMutableDictionary *eventBlockListeners;
	
	NSMutableDictionary *channels;
	NSMutableArray *subscribeQueue;
}
@property (nonatomic, readonly)		NSString *APIKey;
@property (nonatomic, readonly)		NSString *socketID;
@property (nonatomic, copy)			NSString *host;
@property (nonatomic, assign)		NSUInteger port;
@property (nonatomic, assign)		id <PTPusherDelegate, PTPusherChannelDelegate> delegate;
@property (nonatomic, assign)		BOOL reconnect;

- (id)initWithKey:(NSString *)key delegate:(id <PTPusherDelegate, PTPusherChannelDelegate>)_delegate;

- (void)addEventListener:(NSString *)eventName block:(void (^)(PTPusherEvent *event))block;
- (void)addEventListener:(NSString *)event target:(id)target selector:(SEL)selector;

- (PTPusherChannel *)subscribeToChannel:(NSString *)name withAuthPoint:(NSURL *)authPoint delegate:(id <PTPusherChannelDelegate>)_delegate;
- (void)unsubscribeFromChannel:(PTPusherChannel	*)channel;
- (PTPusherChannel *)channelWithName:(NSString *)name;

- (void)sendToSocket:(NSString *)message;
- (void)sendEvent:(NSString *)eventName data:(NSDictionary *)dataLoad;

+ (NSString *)key;
+ (void)setKey:(NSString *)apiKey;
+ (NSString *)secret;
+ (void)setSecret:(NSString *)secret;
+ (NSString *)appID;
+ (void)setAppID:(NSString *)appId;

@end

@protocol PTPusherChannelProtocol
@required
- (void)eventReceived:(PTPusherEvent *)event;
@end


