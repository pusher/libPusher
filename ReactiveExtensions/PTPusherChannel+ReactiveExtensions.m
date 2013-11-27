//
//  PTPusherChannel+ReactiveExtensions.m
//  libPusher
//
//  Created by Luke Redpath on 27/11/2013.
//
//

#import "PTPusherChannel+ReactiveExtensions.h"
#import "PTPusher+ReactiveExtensions.h"

@implementation PTPusherChannel (ReactiveExtensions)

- (RACSignal *)eventsOfType:(NSString *)eventName
{
  return [PTPusher signalForEvents:eventName onBindable:self];
}

@end
