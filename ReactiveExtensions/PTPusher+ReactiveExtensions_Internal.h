//
//  PTPusherChannel_PTPusher_ReactiveExtensions_Internal_h.h
//  libPusher
//
//  Created by Luke Redpath on 27/11/2013.
//
//

#import <ReactiveCocoa/NSNotificationCenter+RACSupport.h>
#import "PTPusher.h"

@interface PTPusher (ReactiveExtensionsInternal)

+ (RACSignal *)signalForEvents:(NSString *)eventName onBindable:(id<PTPusherEventBindings>)bindable;
+ (RACSignal *)signalForAllEventsOnBindable:(id<PTPusherEventBindings>)bindable;

@end
