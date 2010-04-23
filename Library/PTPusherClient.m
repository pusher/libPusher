//
//  PTPusherClient.m
//  libPusher
//
//  Created by Luke Redpath on 23/04/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTPusherClient.h"
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

@implementation PTPusherClient

- (id)initWithAppID:(NSString *)_id key:(NSString *)_key secret:(NSString *)_secret;
{
  if (self = [super init]) {
    appid = [_id copy];
    APIKey = [_key copy];
    secret = [_secret copy];
    operationQueue = [[NSOperationQueue alloc] init];
  }
  return self;
}

- (void)dealloc;
{
  [operationQueue release];
  [appid release];
  [APIKey release];
  [secret release];
  [super dealloc];
}

- (void)triggerEvent:(NSString *)name channel:(NSString *)channel data:(id)data;
{
  NSString *path = [NSString stringWithFormat:@"/apps/%@/channels/%@/events", appid, channel];
  NSString *body = [data JSONRepresentation];
  
  NSMutableDictionary *queryParameters = [NSMutableDictionary dictionary];
  [queryParameters setValue:[[body MD5Hash] lowercaseString] forKey:@"body_md5"];
  [queryParameters setValue:APIKey forKey:@"auth_key"];
  [queryParameters setValue:[NSNumber numberWithDouble:time(NULL)] forKey:@"auth_timestamp"];
  [queryParameters setValue:@"1.0" forKey:@"auth_version"];
  [queryParameters setValue:name forKey:@"name"];

  NSString *signatureQuery = [queryParameters sortedQueryString];
  NSMutableString *signatureString = [NSMutableString stringWithFormat:@"POST\n%@\n%@", path, signatureQuery];
  NSString *signature = generateBase64EncodedHMAC(signatureString, secret);
  
  [queryParameters setValue:[signature stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] forKey:@"auth_signature"];
  
  NSString *resourceString = [NSString stringWithFormat:@"http://%@%@?%@", kPTPusherWebServiceHost, path, [queryParameters sortedQueryString]];
  
  PTPusherClientOperation *operation = [[PTPusherClientOperation alloc] initWithURL:[NSURL URLWithString:resourceString] JSONString:body];
  [operationQueue addOperation:operation];
  [operation release];
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

