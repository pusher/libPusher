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

#import <CommonCrypto/CommonHMAC.h>

#define kPTPusherWebServiceHost @"api.pusherapp.com"

NSString *generateEncodedHMAC(NSString *string, NSString *secret) {
  const char *cKey  = [secret cStringUsingEncoding:NSASCIIStringEncoding];
  const char *cData = [string cStringUsingEncoding:NSASCIIStringEncoding];
  
  unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
  
  CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);

	NSMutableString *result = [[NSMutableString alloc] init];
	for (int i = 0; i < sizeof(cHMAC); i++) {
		[result appendFormat:@"%02x", cHMAC[i] & 0xff];
	}
  NSString *digest = [result copy];
  [result release];
  
  return [digest autorelease];
}

NSString *URLEncodedString(NSString *unencodedString) {
  return (NSString *)CFURLCreateStringByAddingPercentEscapes(
     NULL, (CFStringRef)unencodedString, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
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
  pusher.delegate = self;
  pusher.reconnect = YES;
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
  
  [queryParameters setValue:generateEncodedHMAC(signatureString, secret) forKey:@"auth_signature"];
  
  NSString *resourceString = [NSString stringWithFormat:@"http://%@%@?%@", kPTPusherWebServiceHost, path, [queryParameters sortedQueryString]];
  
  PTPusherClientOperation *operation = [[PTPusherClientOperation alloc] initWithURL:[NSURL URLWithString:resourceString] JSONString:body];
  operation.delegate = self.delegate;
  operation.channel = self;
  [operationQueue addOperation:operation];
  [operation release];
}

#pragma mark -
#pragma mark Private

- (void)pusherDidConnect:(PTPusher *)pusher
{
  [self.delegate channelDidConnect:self];
}

- (void)pusherDidDisconnect:(PTPusher *)pusher
{
  [self.delegate channelDidDisconnect:self];
}

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

@synthesize delegate;
@synthesize channel;

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
  
  NSHTTPURLResponse *response = nil;
  NSError *error = nil;
  
  [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
  [request release];
  
  if (error != nil) {
    if (self.channel && [self.delegate respondsToSelector:@selector(channelFailedToTriggerEvent:error:)]) {
      [self.delegate channelFailedToTriggerEvent:self.channel error:error];
    }
  } else {
    if ([response statusCode] == 202) {
      if (self.channel && [self.delegate respondsToSelector:@selector(channelDidTriggerEvent:)]) {
        [self.delegate channelDidTriggerEvent:self.channel];
      } 
    } else {
      if (self.channel && [self.delegate respondsToSelector:@selector(channelFailedToTriggerEvent:error:)]) {
        NSError *error = [NSError errorWithDomain:@"PTPusherOperationFailed" code:[response statusCode] userInfo:[NSDictionary dictionaryWithObject:response forKey:@"response"]];
        [self.delegate channelFailedToTriggerEvent:self.channel error:error];
      }
    }    
  }
}

@end

