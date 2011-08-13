//
//  PTTargetActionEventListener.h
//  libPusher
//
//  Created by Luke Redpath on 14/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTEventListener.h"
#import "PTPusherEventDispatcher.h"


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

@interface PTPusherEventDispatcher (PTTargetActionFactory)

/** A convenience method for adding a new target/action event listener.
 */
- (void)addEventListenerForEventNamed:(NSString *)eventName target:(id)target action:(SEL)action;

@end
