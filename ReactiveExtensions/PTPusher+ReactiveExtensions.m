//
//  PTPusher+ReactiveExtensions.m
//  libPusher
//
//  Created by Luke Redpath on 27/11/2013.
//
//

#import "PTPusher+ReactiveExtensions.h"

@implementation PTPusher (ReactiveExtensions)

+ (RACSignal *)signalForEvents:(NSString *)eventName onBindable:(id<PTPusherEventBindings>)bindable
{
  return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    PTPusherEventBinding *binding = [bindable bindToEventNamed:eventName handleWithBlock:^(PTPusherEvent *event) {
      [subscriber sendNext:event];
    }];
    
    return [RACDisposable disposableWithBlock:^{
      [bindable removeBinding:binding];
    }];
    
  }] setNameWithFormat:@"-eventsOfType:%@ onBindable:%@", eventName, bindable];

}

- (RACSignal *)eventsOfType:(NSString *)eventName
{
  return [[self class] signalForEvents:eventName onBindable:self];
}

@end
