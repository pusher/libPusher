//
//  PTEventListener.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PTPusherEvent;

@interface PTEventListener : NSObject {
  id target;
  SEL selector;
}
- (id)initWithTarget:(id)_target selector:(SEL)_selector;
- (void)dispatch:(PTPusherEvent *)eventData;
@end
