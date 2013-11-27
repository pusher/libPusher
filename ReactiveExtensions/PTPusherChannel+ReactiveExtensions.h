//
//  PTPusherChannel+ReactiveExtensions.h
//  libPusher
//
//  Created by Luke Redpath on 27/11/2013.
//
//

#import <Pusher/Pusher.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface PTPusherChannel (ReactiveExtensions)

/** Returns a signal that emits events as they arrive this channel.
 */
- (RACSignal *)eventsOfType:(NSString *)eventName;

@end
