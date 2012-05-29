//
//  PTPusherEventDispatcher.h
//  libPusher
//
//  Created by Luke Redpath on 13/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTEventListener.h"

@class PTPusherEventBinding;

@interface PTPusherEventDispatcher : NSObject <PTEventListener> 

@property (nonatomic, readonly) NSDictionary *bindings;

- (PTPusherEventBinding *)addEventListener:(id<PTEventListener>)listener forEventNamed:(NSString *)eventName;
- (void)removeBinding:(PTPusherEventBinding *)binding;
- (void)removeAllBindings;
@end

@interface PTPusherEventBinding : NSObject <PTEventListener>

/** The event this binding binds to. */
@property (nonatomic, readonly) NSString *eventName;

/** Returns YES if this binding is still attached to its event publisher.
  
 Retained references to bindings can become invalid as a result of another object
 calling removeBinding: with this binding or removeAllBindings.
 
 You can safely discard invalid binding instances.
 */
@property (nonatomic, readonly, getter=isValid) BOOL valid;

- (id)initWithEventListener:(id<PTEventListener>)eventListener eventName:(NSString *)eventName;
@end
