//
//  PTBlockEventListener.h
//  libPusher
//
//  Created by Luke Redpath on 14/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTEventListener.h"
#import "PTPusherEventDispatcher.h"

@class PTPusherEvent;

typedef void (^PTBlockEventListenerBlock)(PTPusherEvent *);

/** Dispatches events using block-based callbacks
 
 As well as specifying a block, a dispatch queue can also be specified. All
 event blocks will be dispatched using GCD on the specified queue.
 */
@interface PTBlockEventListener : NSObject <PTEventListener> {
  PTBlockEventListenerBlock block;
  dispatch_queue_t queue;
}
- (id)initWithBlock:(PTBlockEventListenerBlock)aBlock dispatchQueue:(dispatch_queue_t)queue;
@end

@interface PTPusherEventDispatcher (PTBlockEventFactory)

/** A convenience method for adding a new block-based event listener.
 */
- (void)addEventListenerForEventNamed:(NSString *)eventName 
                                block:(PTBlockEventListenerBlock)block 
                                queue:(dispatch_queue_t)queue;

@end

