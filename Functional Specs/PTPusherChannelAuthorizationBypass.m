//
//  PTPusherChannelAuthorizationBypass.m
//  libPusher
//
//  Created by Luke Redpath on 06/05/2013.
//
//

#import "PTPusherChannelAuthorizationBypass.h"

@implementation PTPusherChannelAuthorizationBypass

- (void)pusherChannel:(PTPusherChannel *)channel requiresAuthorizationForSocketID:(NSString *)socketID completionHandler:(void (^)(BOOL, NSDictionary *, NSError *))completionHandler
{
  completionHandler(YES, @{}, nil);
}

@end
