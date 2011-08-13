//
//  PTPusherEvent.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PTPusherEvent : NSObject {

}
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) id data;

- (id)initWithEventName:(NSString *)name data:(id)data;
@end
