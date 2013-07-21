//
//  PTPusherChannelAuthorizationOperation.h
//  libPusher
//
//  Created by Luke Redpath on 14/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTURLRequestOperation.h"

typedef enum {
  PTPusherChannelAuthorizationConnectionError = 100,
  PTPusherChannelAuthorizationBadResponseError
} PTPusherChannelAuthorizationError;

@interface PTPusherChannelAuthorizationOperation : PTURLRequestOperation

@property (nonatomic, copy) void (^completionHandler)(PTPusherChannelAuthorizationOperation *);
@property (nonatomic, readonly, getter=isAuthorized) BOOL authorized;
@property (nonatomic, strong, readonly) NSDictionary *authorizationData;
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0
@property (weak, nonatomic, readonly) NSMutableURLRequest *mutableURLRequest;
#else
@property (unsafe_unretained, nonatomic, readonly) NSMutableURLRequest *mutableURLRequest;
#endif
@property (nonatomic, readonly) NSError *error;

+ (id)operationWithAuthorizationURL:(NSURL *)URL channelName:(NSString *)channelName socketID:(NSString *)socketID;
@end
