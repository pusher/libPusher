//
//  PTPusherClient.h
//  libPusher
//
//  Created by Luke Redpath on 23/04/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTPusherEventPublisher.h"
#import "PTEventListener.h"
#import "PTPusherEventDispatcher.h"
#import "PTPusherPresenceChannelDelegate.h"


@class PTPusher;

@interface PTPusherChannel : NSObject <PTPusherEventEmmitter, PTEventListener> {
  NSString *name;
  PTPusher *pusher;
  PTPusherEventDispatcher *dispatcher;
}
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly, getter=isSubscribed) BOOL subscribed;
@property (nonatomic, readonly) BOOL isPrivate;
@property (nonatomic, readonly) BOOL isPresence;

///------------------------------------------------------------------------------------/
/// @name Initialisation
///------------------------------------------------------------------------------------/

+ (id)channelWithName:(NSString *)name pusher:(PTPusher *)pusher;

- (id)initWithName:(NSString *)channelName pusher:(PTPusher *)pusher;

///------------------------------------------------------------------------------------/
/// @name Authorization
///------------------------------------------------------------------------------------/

- (void)authorizeWithCompletionHandler:(void(^)(BOOL, NSDictionary *))completionHandler;

///------------------------------------------------------------------------------------/
/// @name Triggering events
///------------------------------------------------------------------------------------/

- (void)triggerEventNamed:(NSString *)eventName data:(id)eventData;
@end

@interface PTPusherPrivateChannel : PTPusherChannel
@end

@interface PTPusherPresenceChannel : PTPusherPrivateChannel {
  NSMutableDictionary *members;
}
@property (nonatomic, assign) id<PTPusherPresenceChannelDelegate> presenceDelegate;
@property (nonatomic, readonly) NSDictionary *members;
@end
