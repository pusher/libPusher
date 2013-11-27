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

- (RACSignal *)eventsOfType:(NSString *)eventName;

@end
