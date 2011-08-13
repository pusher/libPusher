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

/** Describes an objects that publish events.
 */
@protocol PTPusherEventPublisher <NSObject>

- (void)bindToEventNamed:(NSString *)eventName target:(id)target action:(SEL)selector;

@optional

// marking this as optional as they will be implemented later

- (void)bindToEventNamed:(NSString *)eventName handleWithBlock:(PTPusherEventBlockHandler)block;

@end
