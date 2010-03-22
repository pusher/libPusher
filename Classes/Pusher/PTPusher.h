//
//  PTPusher.h
//  PusherEvents
//
//  Created by Luke Redpath on 22/03/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PTPusher : NSObject {
  NSString *APIKey;
  NSString *channel;
  NSMutableDictionary *eventListeners;
}
@property (nonatomic, readonly) NSString *APIKey;
@property (nonatomic, readonly) NSString *channel;

- (id)initWithKey:(NSString *)key channel:(NSString *)channelName;
- (void)addEventListener:(NSString *)event target:(id)target selector:(SEL)selector;
@end


