//
//  PTPusherChannelAuthorizationStrategy.h
//  libPusher
//
//  Created by Luke Redpath on 05/05/2013.
//
//

#import <Foundation/Foundation.h>

@class PTPusherChannel;

/* Describes the authorization protocol used by the PTPusher client
 * when a channel requires authorization to subscribe.
 *
 * You can implement your own authorization strategy by creating a
 * class that conforms to this protocol.
 */
@protocol PTPusherChannelAuthorization <NSObject>

/* Called when a channel requires authorization.
 *
 * Implementations should do whatever they need to do to authorize channel access
 * (e.g. make an HTTP request to some server that returns the necessary authorization
 * data) and then call the completion handler, indicating whether or not authorization
 * was successful and passing the authorization data or an error as necessary.
 */
- (void)authorizeChannel:(PTPusherChannel *)channel socketID:(NSString *)socketID completionHandler:(void(^)(BOOL isAuthorized, NSDictionary *authData, NSError *error))completionHandler;

@optional

/* This will be called by the Pusher client when it disconnects.
 *
 * Asynchronous authorization strategies can implement this method to cancel any
 * outstanding authorization attempts when the client disconnects.
 */
- (void)cancelAuthorization;

@end
