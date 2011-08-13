//
//  PTPusherClient.h
//  libPusher
//
//  Created by Luke Redpath on 23/04/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTPusherChannelDelegate.h"
#import "PTPusherEventPublisher.h"
#import "PTEventListener.h"
#import "PTPusherEventDispatcher.h"


@class PTPusher;

@interface PTPusherChannel : NSObject <PTPusherEventPublisher, PTEventListener> {
  NSString *name;
  PTPusher *pusher;
  PTPusherEventDispatcher *dispatcher;
  id<PTPusherChannelDelegate> delegate;
}
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, assign) id<PTPusherChannelDelegate> delegate;

///------------------------------------------------------------------------------------/
/// @name Initialisation
///------------------------------------------------------------------------------------/

- (id)initWithName:(NSString *)channelName pusher:(PTPusher *)pusher;

///------------------------------------------------------------------------------------/
/// @name Triggering events
///------------------------------------------------------------------------------------/

- (void)triggerEventNamed:(NSString *)eventName data:(id)eventData;
@end
