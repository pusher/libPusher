//
//  PTPusherEventDispatcher.h
//  libPusher
//
//  Created by Luke Redpath on 13/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTEventListener.h"

@class PTPusherEventBinding;

@interface PTPusherEventDispatcher : NSObject <PTEventListener> 
- (PTPusherEventBinding *)addEventListener:(id<PTEventListener>)listener forEventNamed:(NSString *)eventName;
- (void)removeBinding:(PTPusherEventBinding *)binding;
@end

@interface PTPusherEventBinding : NSObject <PTEventListener>

@property (nonatomic, readonly) NSString *eventName;

- (id)initWithEventListener:(id<PTEventListener>)eventListener eventName:(NSString *)eventName;
@end
