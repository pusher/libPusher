//
//  PTJSON.m
//  libPusher
//
//  Created by Luke Redpath on 30/03/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import "PTJSON.h"
#import "PTPusherMacros.h"

@interface PTNSJSONParser : NSObject <PTJSONParser>
+ (instancetype)NSJSONParser;
@end

@implementation PTJSON

+ (id<PTJSONParser>)JSONParser
{
  return [PTNSJSONParser NSJSONParser];
}

@end

@implementation PTNSJSONParser 

+ (instancetype)NSJSONParser
{
  PT_DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
    return [[self alloc] init];
  });
}

- (NSData *)JSONDataFromObject:(id)object error:(NSError *__autoreleasing *)error
{
  return [NSJSONSerialization dataWithJSONObject:object options:0 error:error];
}

- (NSString *)JSONStringFromObject:(id)object error:(NSError *__autoreleasing *)error
{
  return [[NSString alloc] initWithData:[self JSONDataFromObject:object error:error] encoding:NSUTF8StringEncoding];
}

- (id)objectFromJSONData:(NSData *)data error:(NSError *__autoreleasing *)error
{
  return [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
}

- (id)objectFromJSONString:(NSString *)string error:(NSError *__autoreleasing *)error
{
  return [self objectFromJSONData:[string dataUsingEncoding:NSUTF8StringEncoding] error:error];
}

@end
