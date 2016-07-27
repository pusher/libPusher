//
//  PTNativePusher.m
//  libPusher
//
//  Created by James Fisher on 25/07/2016.
//
//

#import "PTNativePusher.h"

NSString *const PLATFORM_TYPE = @"apns";
NSString *const CLIENT_API_V1_ENDPOINT = @"https://nativepushclient-cluster1.pusher.com/client_api/v1";

const int MAX_FAILED_REQUEST_ATTEMPTS = 6;

// FIXME free() of below vars? ref counting?
@implementation PTNativePusher {
  NSURLSession * urlSession;
  int failedNativeServiceRequests;
  NSString * pusherAppKey;
  NSString * clientId;
  NSMutableArray * outbox;
}

- (id)initWithPusherAppKey:(NSString *)_pusherAppKey {
  if (self = [super init]) {
    self->urlSession = [NSURLSession sharedSession];
    self->failedNativeServiceRequests = 0;
    self->pusherAppKey = _pusherAppKey;
    self->clientId = NULL;  // NULL until we register
    self->outbox = [NSMutableArray array];
  }
  return self;
}

// Lovingly borrowed from http://stackoverflow.com/a/16411517/229792
- (NSString *) deviceTokenToString:(NSData *)deviceToken {
  const char *data = [deviceToken bytes];
  NSMutableString *token = [NSMutableString string];
  
  for (NSUInteger i = 0; i < [deviceToken length]; i++) {
    [token appendFormat:@"%02.2hhX", data[i]];
  }
  
  return [token copy];
}

- (void) registerWithDeviceToken: (NSData*) deviceToken {
  NSMutableURLRequest * request =
  [NSMutableURLRequest requestWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@", CLIENT_API_V1_ENDPOINT, @"/clients"]]];
  [request setHTTPMethod:@"POST"];
  
  NSString* deviceTokenString = [self deviceTokenToString:deviceToken];
  
  NSDictionary * params = @{
    @"app_key": self->pusherAppKey,
    @"platform_type": PLATFORM_TYPE,
    @"token": deviceTokenString
    // TODO client name/version
  };
  
  assert([NSJSONSerialization isValidJSONObject:params]);
  
  [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:params options:@[] error: NULL]]; // FIXME error NULL?
  
  // FIXME what encoding does the above ^ serialization use? UTF-8?
  [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
  NSURLSessionDataTask * task = [urlSession dataTaskWithRequest:request
                                              completionHandler: ^(NSData * data, NSURLResponse * response, NSError * error) {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*) response;
    if ([httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300) {
      NSError * jsonDecodingError;
      id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:@[] error:&jsonDecodingError];
      // FIXME check jsonDecodingError
      NSDictionary* jsonDict = (NSDictionary*) jsonObj;
      NSObject * clientIdObj = [jsonDict objectForKey:@"id"];
      NSString * clientIdString = (NSString*) clientIdObj;
      self->clientId = clientIdString;
      [self tryFlushOutbox];
    } else {
      // TODO error
    }
  }];
  [task resume];
}

- (void) subscribe:(NSString *)interestName {
  // TODO using a dictionary here is kinda horrible
  [self->outbox addObject:@{ @"interestName": interestName, @"change": @"subscribe" }];
  [self tryFlushOutbox];
}

- (void) unsubscribe:(NSString *)interestName {
  [self->outbox addObject:@{ @"interestName": interestName, @"change": @"unsubscribe" }];
  [self tryFlushOutbox];
}

- (void) tryFlushOutbox {
  if (self->clientId != NULL && 0 < [self->outbox count]) {
    NSDictionary* subscriptionChange = (NSDictionary*) [self->outbox objectAtIndex:0];
    NSString* interestName = (NSString*) [subscriptionChange objectForKey:@"interestName"];
    NSString* change = (NSString*) [subscriptionChange objectForKey:@"change"];
    [self
     modifySubscriptionForPusherAppKey:self->pusherAppKey
     clientId:self->clientId
     interestName:interestName
     subscriptionChange:change
     callback: ^() { [self tryFlushOutbox]; }];
  }
}

- (void) modifySubscriptionForPusherAppKey:(NSString*) _pusherAppKey clientId: (NSString*) _clientId interestName: (NSString*) interestName subscriptionChange: (NSString*) subscriptionChange callback: (void(^)(void)) callback {
  NSString* url = [NSString stringWithFormat:@"%@/clients/%@/interests/%@", CLIENT_API_V1_ENDPOINT, _clientId, interestName];
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:url]];
  
  if ([subscriptionChange isEqualToString:@"subscribe"]) {
    [request setHTTPMethod:@"POST"];
  } else if ([subscriptionChange isEqualToString:@"subscribe"]) {
    [request setHTTPMethod:@"DELETE"];
  }
  
  NSDictionary* params = @{
    @"app_key": _pusherAppKey
    // TODO client name/version
    };
  
  [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:params options:@[] error:NULL]]; // TODO error??
  [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"]; // TODO charset
  
  NSURLSessionDataTask* task = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*) response;
    if ([httpResponse statusCode] >= 200 && [httpResponse statusCode] < 300) {
      // Reset number of failed requests to 0 upon success
      self->failedNativeServiceRequests = 0;
      
      callback();
    } else {
      [self->outbox insertObject:@{ @"interestName": interestName, @"change": subscriptionChange } atIndex:0];
      
      if (error != nil) {
        // TODO print error
      } else {
        // TODO print error
      }
      
      self->failedNativeServiceRequests += 1;
      
      if (self->failedNativeServiceRequests < MAX_FAILED_REQUEST_ATTEMPTS) {
        callback();
      } else {
        // TODO print error
      }
      // TODO error
    }
  }];
  [task resume];
}

@end