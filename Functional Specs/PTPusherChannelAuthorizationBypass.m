//
//  PTPusherChannelAuthorizationBypass.m
//  libPusher
//
//  Created by Luke Redpath on 06/05/2013.
//
//

#import "PTPusherChannelAuthorizationBypass.h"
#import "PTPusherChannel.h"

@implementation PTPusherChannelAuthorizationBypass

- (void)pusherChannel:(PTPusherChannel *)channel requiresAuthorizationForSocketID:(NSString *)socketID completionHandler:(void (^)(BOOL, NSDictionary *, NSError *))completionHandler
{
  if (channel.isPresence) {
    completionHandler(YES, @{ @"channel_data": @"{\"user_id\":\"12345\"}" }, nil);
  } else {
    completionHandler(YES, @{}, nil);
  }
}

@end
