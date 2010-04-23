//
//  PTPusherClient.h
//  libPusher
//
//  Created by Luke Redpath on 23/04/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTPusherChannelDelegate.h"
#import "PTPusherDelegate.h"

@class PTPusher;

@interface PTPusherChannel : NSObject <PTPusherDelegate> {
  NSString *name;
  NSString *appid;
  NSString *APIKey;
  NSString *secret;
  NSOperationQueue *operationQueue;
  PTPusher *pusher;
  id<PTPusherChannelDelegate> delegate;
}
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, assign) id<PTPusherChannelDelegate> delegate;

- (id)initWithName:(NSString *)channelName 
             appID:(NSString *)_id 
               key:(NSString *)_key 
            secret:(NSString *)_secret;

- (void)triggerEvent:(NSString *)name data:(id)data;
- (void)startListeningForEvents;
- (void)stopListeningForEvents;
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

