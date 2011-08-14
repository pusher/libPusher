//
//  PTPusherEventPublisher.h
//  libPusher
//
//  Created by Luke Redpath on 13/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PTPusherEvent;

typedef void (^PTPusherEventBlockHandler) (PTPusherEvent *);

/** Describes an objects that emits events that can be bound to.
 */
@protocol PTPusherEventEmmitter <NSObject>

- (void)bindToEventNamed:(NSString *)eventName target:(id)target action:(SEL)selector;
- (void)bindToEventNamed:(NSString *)eventName handleWithBlock:(PTPusherEventBlockHandler)block;
- (void)bindToEventNamed:(NSString *)eventName handleWithBlock:(PTPusherEventBlockHandler)block queue:(dispatch_queue_t)queue;

@end
