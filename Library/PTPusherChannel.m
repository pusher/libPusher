//
//  PTPusherClient.m
//  libPusher
//
//  Created by Luke Redpath on 23/04/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTPusherChannel.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "JSON.h"
#import "NSString+Hashing.h"
#import "NSDictionary+QueryString.h"
#import "NSData+Base64.h"
#import <CommonCrypto/CommonHMAC.h>

#define kPTPusherWebServiceHost @"api.pusherapp.com"

NSString *generateBase64EncodedHMAC(NSString *string, NSString *secret) {
  const char *cKey  = [secret cStringUsingEncoding:NSASCIIStringEncoding];
  const char *cData = [string cStringUsingEncoding:NSASCIIStringEncoding];
  
  unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
  
  CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
  
  return [[NSData dataWithBytes:cHMAC length:sizeof(cHMAC)] base64EncodedString];
}

@implementation PTPusherChannel

@synthesize name;
@synthesize delegate;

- (id)initWithName:(NSString *)channelName appID:(NSString *)_id key:(NSString *)_key secret:(NSString *)_secret;
{
  if (self = [super init]) {
    name = [channelName copy];
    appid = [_id copy];
    APIKey = [_key copy];
    secret = [_secret copy];
    operationQueue = [[NSOperationQueue alloc] init];
    pusher = nil;
    delegate = nil;
  }
  return self;
}

- (void)dealloc;
{
  if (pusher != nil) {
    [[NSNotificationCenter defaultCenter] removeObserver:self 
      name:PTPusherEventReceivedNotification object:nil];
  }
  [pusher release];
  [name release];
  [operationQueue release];
  [appid release];
  [APIKey release];
  [secret release];
  [super dealloc];
}

- (void)startListeningForEvents;
{
  [pusher release];
  pusher = [[PTPusher alloc] initWithKey:APIKey channel:name];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedEventNotification:) name:PTPusherEventReceivedNotification object:nil];
}

- (void)stopListeningForEvents;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self 
    name:PTPusherEventReceivedNotification object:nil];
  [pusher release];
  pusher = nil;
}

- (void)triggerEvent:(NSString *)event data:(id)data;
{
  NSString *path = [NSString stringWithFormat:@"/apps/%@/channels/%@/events", appid, name];
  NSString *body = [data JSONRepresentation];
  
  NSMutableDictionary *queryParameters = [NSMutableDictionary dictionary];
  [queryParameters setValue:[[body MD5Hash] lowercaseString] forKey:@"body_md5"];
  [queryParameters setValue:APIKey forKey:@"auth_key"];
  [queryParameters setValue:[NSNumber numberWithDouble:time(NULL)] forKey:@"auth_timestamp"];
  [queryParameters setValue:@"1.0" forKey:@"auth_version"];
  [queryParameters setValue:event forKey:@"name"];

  NSString *signatureQuery = [queryParameters sortedQueryString];
  NSMutableString *signatureString = [NSMutableString stringWithFormat:@"POST\n%@\n%@", path, signatureQuery];
  NSString *signature = generateBase64EncodedHMAC(signatureString, secret);
  
  [queryParameters setValue:[signature stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] forKey:@"auth_signature"];
  
  NSString *resourceString = [NSString stringWithFormat:@"http://%@%@?%@", kPTPusherWebServiceHost, path, [queryParameters sortedQueryString]];
  
  PTPusherClientOperation *operation = [[PTPusherClientOperation alloc] initWithURL:[NSURL URLWithString:resourceString] JSONString:body];
  [operationQueue addOperation:operation];
  [operation release];
}

#pragma mark -
#pragma mark Private

- (void)receivedEventNotification:(NSNotification *)note;
{
  PTPusherEvent *event = (PTPusherEvent *)note.object;
  if ([event.channel isEqualToString:name]) {
    if ([self.delegate respondsToSelector:@selector(channel:didReceiveEvent:)]) {
      [self.delegate channel:self didReceiveEvent:event];
    }
  }
}

@end

@implementation PTPusherClientOperation

- (id)initWithURL:(NSURL *)_url JSONString:(NSString *)json;
{
  if (self = [super init]) {
    url = [_url copy];
    body = [json copy];
  }
  return self;
}

- (void)dealloc;
{
  [url release];
  [body release];
  [super dealloc];
}

- (void)main
{
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
  [request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
  [request setHTTPMethod:@"POST"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
  NSHTTPURLResponse *response;
  NSError *error;
  
  NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
  
  if (error != nil) {
    NSLog(@"Connection error: %@", error);
  } else {
    NSLog(@"Success! %@, %@", [NSHTTPURLResponse localizedStringForStatusCode:[response statusCode]], [NSString stringWithUTF8String:[data bytes]]);
  }
}

@end

