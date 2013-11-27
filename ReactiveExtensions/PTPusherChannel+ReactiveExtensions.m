//
//  PTPusherChannel+ReactiveExtensions.m
//  libPusher
//
//  Created by Luke Redpath on 27/11/2013.
//
//

#import "PTPusherChannel+ReactiveExtensions.h"
#import "PTPusherEventPublisher.h"

@implementation PTPusherChannel (ReactiveExtensions)

- (RACSignal *)eventsOfType:(NSString *)eventName
{
  return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    PTPusherEventBinding *binding = [self bindToEventNamed:eventName handleWithBlock:^(PTPusherEvent *event) {
      [subscriber sendNext:event];
    }];
    
    return [RACDisposable disposableWithBlock:^{
      [self removeBinding:binding];
    }];
    
  }] setNameWithFormat:@"-eventsOfType:%@ onChannel:%@", eventName, self.name];
}

@end
