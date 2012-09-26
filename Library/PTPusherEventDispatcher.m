//
//  PTPusherEventDispatcher.m
//  libPusher
//
//  Created by Luke Redpath on 13/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import "PTPusherEventDispatcher.h"
#import "PTPusherEvent.h"

@interface PTPusherEventBinding ()
- (void)invalidate;
@end

@implementation PTPusherEventDispatcher {
  NSMutableDictionary *bindings;
}

@synthesize bindings;

- (id)init
{
  if ((self = [super init])) {
    bindings = [[NSMutableDictionary alloc] init];
  }
  return self;
}

#pragma mark - Managing event listeners

- (PTPusherEventBinding *)addEventListener:(id<PTEventListener>)listener forEventNamed:(NSString *)eventName
{
  NSMutableArray *bindingsForEvent = [bindings objectForKey:eventName];
  
  if (bindingsForEvent == nil) {
    bindingsForEvent = [NSMutableArray array];
    [bindings setObject:bindingsForEvent forKey:eventName];
  }
  PTPusherEventBinding *binding = [[PTPusherEventBinding alloc] initWithEventListener:listener eventName:eventName];
  [bindingsForEvent addObject:binding];
  
  return binding;
}

- (void)removeBinding:(PTPusherEventBinding *)binding
{
  NSMutableArray *bindingsForEvent = [bindings objectForKey:binding.eventName];
  
  if ([bindingsForEvent containsObject:binding]) {
    [binding invalidate];
    [bindingsForEvent removeObject:binding];
  }
}

- (void)removeAllBindings
{
  for (NSArray *eventBindings in [bindings allValues]) {
    for (PTPusherEventBinding *binding in eventBindings) {
	    [binding invalidate];
	  }
  }
  [bindings removeAllObjects];
}

#pragma mark - Dispatching events

- (void)dispatchEvent:(PTPusherEvent *)event
{
  for (PTPusherEventBinding *binding in [bindings objectForKey:event.name]) {
    [binding dispatchEvent:event];
  }
}

@end

@implementation PTPusherEventBinding {
  id<PTEventListener> _eventListener;
}

@synthesize eventName = _eventName;

- (id)initWithEventListener:(id<PTEventListener>)eventListener eventName:(NSString *)eventName
{
  if ((self = [super init])) {
    _eventName = [eventName copy];
    _eventListener = eventListener;
  }
  return self;
}

- (void)invalidate
{
  if ([_eventListener respondsToSelector:@selector(invalidate)]) {
    [_eventListener invalidate];
  }
}

- (void)dispatchEvent:(PTPusherEvent *)event
{
  [_eventListener dispatchEvent:event];
}

@end
