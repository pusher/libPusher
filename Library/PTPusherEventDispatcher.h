//
//  PTPusherEventDispatcher.h
//  libPusher
//
//  Created by Luke Redpath on 13/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTEventListener.h"

/** Dispatches events to multiple event listeners.
 
 PTPusherEventDispatcher is a special event listener to can dispatch events
 to multiple event listeners and forms the basis for all event binding.
 */
@interface PTPusherEventDispatcher : NSObject <PTEventListener> {
  NSMutableDictionary *eventListeners;
}

/** Registers a new event listener for the named event.
 
 @param listener  The event listener.
 @param eventName The name of the event this listener is listening for.
 */
- (void)addEventListener:(id<PTEventListener>)listener forEventNamed:(NSString *)eventName;
@end
