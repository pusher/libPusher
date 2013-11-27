//
//  PTPusher+ReactiveExtensions.h
//  libPusher
//
//  Created by Luke Redpath on 27/11/2013.
//
//

#import <Pusher/Pusher.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PTPusherChannel+ReactiveExtensions.h"

/** Reactive extensions for Pusher provide an alternative means of binding to events,
 * using ReactiveCocoa signals.
 *
 * Each call to eventsOfType: returns a new RACSignal - you can keep a reference to a single
 * signal and re-use safely.
 *
 * Internally, an event binding (PTPusherEventBinding) is created per-subscriber. The binding
 * will be safely removed when the subscription is disposed of.
 *
 * Warning: if you are using ReactiveExtensions, you should be careful when using the method
 * removeAllBindings as this will remove any underlying bindings being used by the signal, 
 * which means the signal will no longer emit events.
 */
@interface PTPusher (ReactiveExtensions)

+ (RACSignal *)signalForEvents:(NSString *)eventName onBindable:(id<PTPusherEventBindings>)bindable;

/** Returns a signal that emits events as they arrive on any channel.
 */
- (RACSignal *)eventsOfType:(NSString *)eventName;

@end
