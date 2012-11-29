//
//  PTPusherChannelAuthorizationOperation.m
//  libPusher
//
//  Created by Luke Redpath on 14/08/2011.
//  Copyright 2011 LJR Software Limited. All rights reserved.
//

#import "PTPusherChannelAuthorizationOperation.h"
#import "NSDictionary+QueryString.h"
#import "PTJSON.h"
#import "PTPusher+Testing.h"

@interface PTPusherChannelAuthorizationBypassOperation : NSOperation
@property (nonatomic, readwrite) NSError *error;
@end

@interface PTPusherChannelAuthorizationOperation ()
@property (nonatomic, strong, readwrite) NSDictionary *authorizationData;
@property (nonatomic, readwrite) NSError *error;
@end

@implementation PTPusherChannelAuthorizationOperation

@synthesize authorized;
@synthesize authorizationData;
@synthesize completionHandler;
@synthesize error;

- (NSMutableURLRequest *)mutableURLRequest
{
  // we can be sure this is always mutable
  return (NSMutableURLRequest *)URLRequest;
}

+ (id)operationWithAuthorizationURL:(NSURL *)URL channelName:(NSString *)channelName socketID:(NSString *)socketID
{
  NSAssert(URL, @"URL is required for authorization! (Did you set PTPusher.authorizationURL?)");
  
  // a short-circuit for testing, using a special URL
  if ([[URL absoluteString] isEqualToString:PTPusherAuthorizationBypassURL]) {
    return [[PTPusherChannelAuthorizationBypassOperation alloc] init];
  }
  
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
  [request setHTTPMethod:@"POST"];
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  
  NSMutableDictionary *requestData = [NSMutableDictionary dictionary];
  [requestData setObject:socketID forKey:@"socket_id"];
  [requestData setObject:channelName forKey:@"channel_name"];
  
  [request setHTTPBody:[[requestData sortedQueryString] dataUsingEncoding:NSUTF8StringEncoding]];
  
  return [[self alloc] initWithURLRequest:request];
}

- (void)finish
{
  if (self.isCancelled) {
    [super finish];
    return;
  }
  
  if (self.connectionError) {
    self.error = [NSError errorWithDomain:PTPusherErrorDomain code:PTPusherChannelAuthorizationConnectionError userInfo:[NSDictionary dictionaryWithObject:self.connectionError forKey:NSUnderlyingErrorKey]];
  }
  else {
    authorized = YES;
    
    if ([URLResponse isKindOfClass:[NSHTTPURLResponse class]]) {
      authorized = ([(NSHTTPURLResponse *)URLResponse statusCode] == 200 || [(NSHTTPURLResponse *)URLResponse statusCode] == 201);
    }
    
    if (authorized) {
      authorizationData = [[PTJSON JSONParser] objectFromJSONData:responseData];
      
      if (![authorizationData isKindOfClass:[NSDictionary class]]) {
        NSDictionary *userInfo = nil;
        
        if (authorizationData) { // make sure it isn't nil as a result of invalid JSON first
          userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"Authorization data was not a dictionary", @"reason", authorizationData, @"authorization_data", nil];
        }
        else {
          userInfo = [NSDictionary dictionaryWithObject:@"Authorization data was not valid JSON" forKey:@"reason"];
        }
        
        self.error = [NSError errorWithDomain:PTPusherErrorDomain code:PTPusherChannelAuthorizationBadResponseError userInfo:userInfo];
        
        authorized = NO;
      }
    }
  }
    
  if (self.completionHandler) {
    self.completionHandler(self);
  }
  
  [super finish];
}

@end

@implementation PTPusherChannelAuthorizationBypassOperation {
  void (^_completionHandler)(id);
}

@synthesize error;

- (void)setCompletionHandler:(void (^)(id))completionHandler
{
  _completionHandler = completionHandler;
}

- (void)main
{
  // we complete after a tiny delay, to simulate the asynchronous nature
  // of channel authorization. The low priorty queue ensures any polling
  // in the test (which probably use the main queue/thread is not broken.
  
  double delayInSeconds = 0.1;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void){
    _completionHandler(self);
  });
}

- (BOOL)isAuthorized
{
  return YES;
}

- (NSDictionary *)authorizationData
{
  return [NSDictionary dictionary];
}

- (NSMutableURLRequest *)mutableURLRequest
{
  return [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:PTPusherAuthorizationBypassURL]];
}

- (NSError *)connectionError
{
  return nil;
}

@end
