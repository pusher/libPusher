//
//  PTEventListener.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PTPusherEvent;

@protocol PTEventListener <NSObject>

/** Dispatches the event.
 
 The mechanism for how the event is dispatched is implementation-specific.
 */
- (void)dispatchEvent:(PTPusherEvent *)event;

@end

/** Dispatches events using the standard Cocoa target/action mechanism.
 
 PTTargetActionEventListener will dispatch events by calling aSelector on
 aTarget. The event will be passed as an argument to the aSelector.
 
 All events will be dispatched asynchronously using Grand Central Dispatch 
 on the main queue.
 */
@interface PTTargetActionEventListener : NSObject <PTEventListener> {
  id target;
  SEL action;
}
- (id)initWithTarget:(id)aTarget action:(SEL)aSelector;
@end
