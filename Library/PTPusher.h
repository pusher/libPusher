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
#import "PTPusherEventPublisher.h"


extern NSString *const PTPusherDataKey;
extern NSString *const PTPusherEventKey;
extern NSString *const PTPusherEventReceivedNotification;

@class PTPusherChannel;
@class PTPusherEventDispatcher;

@interface PTPusher : NSObject <PTPusherConnectionDelegate, PTPusherEventPublisher> {
  PTPusherEventDispatcher *dispatcher;
  NSMutableDictionary *channels;
}
@property (nonatomic, assign) id<PTPusherDelegate> delegate;
@property (nonatomic, assign, getter=shouldReconnectAutomatically) BOOL reconnectAutomatically;
@property (nonatomic, assign) NSTimeInterval reconnectDelay;
@property (nonatomic, readonly, getter=isConnected) BOOL connected;

///------------------------------------------------------------------------------------/
/// @name Initialisation
///------------------------------------------------------------------------------------/

- (id)initWithConnection:(PTPusherConnection *)connection connectAutomatically:(BOOL)connectAutomatically;

+ (id)pusherWithKey:(NSString *)key;

///------------------------------------------------------------------------------------/
/// @name Managing the connection
///------------------------------------------------------------------------------------/

- (void)connect;
- (void)disconnect;

///------------------------------------------------------------------------------------/
/// @name Subscribing to channels
///------------------------------------------------------------------------------------/

/** Subscribes to the named channel.
 
 This method can be used to subscribe to any type of channel, including private and
 presence channels by including the appropriate channel name prefix.
 */
- (PTPusherChannel *)subscribeToChannelNamed:(NSString *)name;

/** Subscribes to the named private channel.
 
 The "private-" prefix should be excluded from the name; it will be added automatically.
 */
- (PTPusherChannel *)subscribeToPrivateChannelNamed:(NSString *)name;

/** Subscribes to the named presence channel.
 
 The "presence-" prefix should be excluded from the name; it will be added automatically.
 */
- (PTPusherChannel *)subscribeToPresenceChannelNamed:(NSString *)name;

- (void)unsubscribeFromChannel:(PTPusherChannel *)channel;
- (PTPusherChannel *)channelNamed:(NSString *)name;

@end

@class PTPusherChannel;

@interface PTPusher (SharedFactory)
+ (void)setKey:(NSString *)apiKey;
+ (void)setSecret:(NSString *)secret;
+ (void)setAppID:(NSString *)appId;
@end

