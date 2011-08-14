//
//  PTPusherEvent.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

/** A value object representing a Pusher event.
 
 All events dispatched by libPusher (via either bindings or notifications) will be represented
 by instances of this class.
 */
@interface PTPusherEvent : NSObject

///------------------------------------------------------------------------------------/
/// @name Properties
///------------------------------------------------------------------------------------/

/** The event name.
 */
@property (nonatomic, readonly) NSString *name;

/** The channel that this event originated from.
 */
@property (nonatomic, readonly) NSString *channel;

/** The event data.
 
 Event data will typically be any kind of object that can be represented as JSON, often
 an NSArray or NSDictionary but can be a simple string.
 */
@property (nonatomic, readonly) id data;

- (id)initWithEventName:(NSString *)name channel:(NSString *)channel data:(id)data;
+ (id)eventFromMessageDictionary:(NSDictionary *)dictionary;
@end
