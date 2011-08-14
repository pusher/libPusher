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


@class PTPusher;

@interface PTPusherChannel : NSObject <PTPusherEventEmmitter, PTEventListener> {
  NSString *name;
  PTPusher *pusher;
  PTPusherEventDispatcher *dispatcher;
}
@property (nonatomic, readonly) NSString *name;

///------------------------------------------------------------------------------------/
/// @name Initialisation
///------------------------------------------------------------------------------------/

- (id)initWithName:(NSString *)channelName pusher:(PTPusher *)pusher;

///------------------------------------------------------------------------------------/
/// @name Authorization
///------------------------------------------------------------------------------------/

- (void)authorizeWithCompletionHandler:(void(^)(NSError *, NSDictionary *))completionHandler;

///------------------------------------------------------------------------------------/
/// @name Triggering events
///------------------------------------------------------------------------------------/

- (void)triggerEventNamed:(NSString *)eventName data:(id)eventData;
@end
