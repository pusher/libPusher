//
//  PTPusher+ReactiveExtensions.m
//  libPusher
//
//  Created by Luke Redpath on 27/11/2013.
//
//

#import "PTPusher+ReactiveExtensions.h"
#import "PTPusher+ReactiveExtensions_Internal.h"

@implementation PTPusher (ReactiveExtensions)

- (RACSignal *)eventsOfType:(NSString *)eventName
{
  return [[self class] signalForEvents:eventName onBindable:self];
}

- (RACSignal *)allEvents
{
  return [[self class] signalForAllEventsOnBindable:self];
}

@end

@implementation PTPusher (ReactiveExtensionsInternal)

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

+ (RACSignal *)signalForAllEventsOnBindable:(id<PTPusherEventBindings>)bindable
{
  RACSignal *notifications = [[NSNotificationCenter defaultCenter] rac_addObserverForName:PTPusherEventReceivedNotification object:bindable];
  
  return [[notifications map:^id(NSNotification *note) {
    return note.userInfo[PTPusherEventUserInfoKey];
  }] setNameWithFormat:@"-allEvents onBindable:%@", bindable];
}

@end
