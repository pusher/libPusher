//
//  PTPusherChannel+ReactiveExtensions.h
//  libPusher
//
//  Created by Luke Redpath on 27/11/2013.
//
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PTPusherChannel.h"

@interface PTPusherChannel (ReactiveExtensions)

/** Returns a signal that emits events as they arrive this channel.
 */
- (RACSignal *)eventsOfType:(NSString *)eventName;

/** Returns a signal that emits all events on this channel.
 */
- (RACSignal *)allEvents;

@end
