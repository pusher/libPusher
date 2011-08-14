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
#import "PTPusherPresenceChannelDelegate.h"


extern NSString *const PTPusherEventReceivedNotification;
extern NSString *const PTPusherEventUserInfoKey;
extern NSString *const PTPusherErrorDomain;
extern NSString *const PTPusherErrorUnderlyingEventKey;

@class PTPusherChannel;
@class PTPusherPresenceChannel;
@class PTPusherPrivateChannel;
@class PTPusherEventDispatcher;

@interface PTPusher : NSObject <PTPusherConnectionDelegate, PTPusherEventEmmitter> {
  PTPusherEventDispatcher *dispatcher;
  NSMutableDictionary *channels;
}
@property (nonatomic, assign) id<PTPusherDelegate> delegate;
@property (nonatomic, assign, getter=shouldReconnectAutomatically) BOOL reconnectAutomatically;
@property (nonatomic, assign) NSTimeInterval reconnectDelay;
@property (nonatomic, retain, readonly) PTPusherConnection *connection;
@property (nonatomic, retain) NSURL *authorizationURL;

///------------------------------------------------------------------------------------/
/// @name Initialisation
///------------------------------------------------------------------------------------/

/** Initialises a new instance with the specified connection.
 
 Clients will rarely call this method directly; to do so would require intialising the
 connection manually. Use the convenience class methods instead.
 
 @param connection The connection used for sending and receiving events
 @param connectAutomatically If YES, the connection will be connected on initialisation.
 */
- (id)initWithConnection:(PTPusherConnection *)connection connectAutomatically:(BOOL)connectAutomatically;

/** Returns a new PTPusher instance with a connection configured with the given key.
 
 Instances created using this method will connect automatically. Specify the delegate here
 to ensure that it is notified about the connection status during connection.
 
 @param key Your application's API key
 @param delegate The delegate for this instance
 */
+ (id)pusherWithKey:(NSString *)key delegate:(id<PTPusherDelegate>)delegate;

/** Initialises a new PTPusher instance with a connection configured with the given key.
 
 If you intend to set a delegate for this instance, you are recommended to set connectAutomatically
 to NO, set the delegate then manually call connect.
 
 @param key Your application's API key
 @param connectAutomatically If YES, the connection will be connected on initialisation.
 */
+ (id)pusherWithKey:(NSString *)key connectAutomatically:(BOOL)connectAutomatically;

///------------------------------------------------------------------------------------/
/// @name Managing the connection
///------------------------------------------------------------------------------------/

/** Establishes a connection to the Pusher server.
 */
- (void)connect;

/** Disconnects from the Pusher server.
 */
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
- (PTPusherPrivateChannel *)subscribeToPrivateChannelNamed:(NSString *)name;

/** Subscribes to the named presence channel.
 
 The "presence-" prefix should be excluded from the name; it will be added automatically.
 */
- (PTPusherPresenceChannel *)subscribeToPresenceChannelNamed:(NSString *)name;
- (PTPusherPresenceChannel *)subscribeToPresenceChannelNamed:(NSString *)name delegate:(id<PTPusherPresenceChannelDelegate>)presenceDelegate;

- (void)unsubscribeFromChannel:(PTPusherChannel *)channel;
- (PTPusherChannel *)channelNamed:(NSString *)name;

///------------------------------------------------------------------------------------/
/// @name Sending events
///------------------------------------------------------------------------------------/

- (void)sendEventNamed:(NSString *)name data:(id)data;
- (void)sendEventNamed:(NSString *)name data:(id)data channel:(NSString *)channelName;

@end

@class PTPusherChannel;

@interface PTPusher (SharedFactory)
+ (void)setKey:(NSString *)apiKey;
+ (void)setSecret:(NSString *)secret;
+ (void)setAppID:(NSString *)appId;
@end

