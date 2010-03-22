//
//  PTPusherEvent.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PTPusherEvent : NSObject {
  NSString *channel;
  NSString *name;
  id data;
}
@property (nonatomic, readonly) NSString *channel;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) id data;

- (id)initWithEventName:(NSString *)eventName data:(id)eventData channel:(NSString *)eventChannel;
@end
