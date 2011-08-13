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


