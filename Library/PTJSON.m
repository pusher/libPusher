//
//  PTJSON.m
//  libPusher
//
//  Created by Luke Redpath on 30/03/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import "PTJSON.h"
#import "JSONKit.h"
#import "PTPusherMacros.h"

@implementation PTJSON

+ (id<PTJSONParser>)JSONParser
{
  return [PTJSONKitParser JSONKitParser];
}

@end

@implementation PTJSONKitParser

+ (id)JSONKitParser
{
  PT_DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
    return [[self alloc] init];
  });
}

- (NSData *)JSONDataFromObject:(id)object
{
  return [object JSONData];
}

- (id)objectFromJSONData:(NSData *)data
{
  return [data objectFromJSONData];
}

- (id)objectFromJSONString:(NSString *)string
{
  return [string objectFromJSONString];
}

@end
