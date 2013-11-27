//
//  PTPusher+ReactiveExtensions.h
//  libPusher
//
//  Created by Luke Redpath on 27/11/2013.
//
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PTPusher.h"
#import "PTPusherChannel+ReactiveExtensions.h"

/** Reactive extensions for Pusher provide an alternative means of binding to events,
 * using ReactiveCocoa signals.
 *
 * Warning: if you are using ReactiveExtensions, you should be careful when using the method
 * removeAllBindings as this will remove any underlying bindings being used by the signal, 
 * which means the signal will no longer emit events.
 */
@interface PTPusher (ReactiveExtensions)

/** Returns a signal that emits events of the given type as they arrive on any channel.
 *
 * Each call to eventsOfType: returns a new RACSignal - you can keep a reference to a single
 * signal and re-use it.
 *
 * Internally, an event binding (PTPusherEventBinding) is created per-subscriber. The binding
 * will be safely removed when the subscription is disposed of.
 */
- (RACSignal *)eventsOfType:(NSString *)eventName;

/** Returns a signal that emits all events on any channel.
 *
 * IMPORTANT NOTE: the allEvents signal is based on notifications that are fired by the 
 * Pusher client. Because notification signals are inifinite (i.e. they do not complete), 
 * there is no way for subscriptions to be disposed of automatically.
 *
 * If you use this method, you are responsible for keeping track of any disposables when
 * subscribing and disposing of them.
 *
 * If you simply wish to subscribe to events until the object that owns the subscription
 * is deallocated (e.g. a view controller), you could use takeUntil: and the dealloc signal,
 * for example:
 *
 *   [[[channel allEvents] takeUntil:[self rac_deallocSignal]] subscribeNext:...]
 */
- (RACSignal *)allEvents;

@end
