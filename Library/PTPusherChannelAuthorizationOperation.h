//
//  PTPusherChannelAuthorizationOperation.h
//  libPusher
//
//  Created by Luke Redpath on 14/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTURLRequestOperation.h"

@interface PTPusherChannelAuthorizationOperation : PTURLRequestOperation

@property (nonatomic, copy) void (^completionHandler)(PTPusherChannelAuthorizationOperation *);
@property (nonatomic, readonly, getter=isAuthorized) BOOL authorized;
@property (nonatomic, retain, readonly) NSDictionary *authorizationData;
@property (nonatomic, readonly) NSMutableURLRequest *mutableURLRequest;

+ (id)operationWithAuthorizationURL:(NSURL *)URL channelName:(NSString *)channelName socketID:(NSString *)socketID;
@end
