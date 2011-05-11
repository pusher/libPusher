//
//  PTEventListener.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PTPusherEvent;

#if NS_BLOCKS_AVAILABLE
typedef void (^PTPusherEventHandlerBlock)(PTPusherEvent *event);
#endif

@interface PTEventListener : NSObject {
	id target;
	SEL selector;
  PTPusherEventHandlerBlock block;
}
- (id)initWithTarget:(id)_target selector:(SEL)_selector;
#if NS_BLOCKS_AVAILABLE
- (id)initWithBlock:(PTPusherEventHandlerBlock)aBlock;
#endif
- (void)dispatch:(PTPusherEvent *)eventData;
@end
