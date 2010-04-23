//
//  PTPusherClient.h
//  libPusher
//
//  Created by Luke Redpath on 23/04/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PTPusherClient : NSObject {
  NSString *appid;
  NSString *APIKey;
  NSString *secret;
  NSOperationQueue *operationQueue;
}
- (id)initWithAppID:(NSString *)_id key:(NSString *)_key secret:(NSString *)_secret;
- (void)triggerEvent:(NSString *)name channel:(NSString *)channel data:(id)data;
@end

@interface PTPusherClientOperation : NSOperation
{
  NSURL *url;
  NSString *body;
}
- (id)initWithURL:(NSURL *)_url JSONString:(NSString *)json;
@end

