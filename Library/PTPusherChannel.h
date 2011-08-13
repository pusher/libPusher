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
  NSOperationQueue *operationQueue;
  id<PTPusherChannelDelegate> delegate;
}
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, assign) id<PTPusherChannelDelegate> delegate;

- (id)initWithName:(NSString *)channelName pusher:(PTPusher *)pusher;
@end

@interface PTPusherClientOperation : NSOperation
{
  NSURL *url;
  NSString *body;
  PTPusherChannel *channel;
  id<PTPusherChannelDelegate> delegate;
}
@property (nonatomic, assign) id<PTPusherChannelDelegate> delegate;
@property (nonatomic, retain) PTPusherChannel *channel;

- (id)initWithURL:(NSURL *)_url JSONString:(NSString *)json;
@end

