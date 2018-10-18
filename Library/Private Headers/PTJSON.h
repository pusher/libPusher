//
//  PTJSON.h
//  libPusher
//
//  Created by Luke Redpath on 30/03/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PTJSONParser <NSObject>

- (NSData *)JSONDataFromObject:(id)object error:(NSError **)error;
- (NSString *)JSONStringFromObject:(id)object error:(NSError **)error;;
- (id)objectFromJSONData:(NSData *)data error:(NSError **)error;
- (id)objectFromJSONString:(NSString *)string error:(NSError **)error;

@end

@interface PTJSON : NSObject

/**
 Returns a JSON parser appropriate for the current platform.
 
 As of libPusher 1.5, the lowest supported deployment target is iOS 5.0
 so this will always return a parser that uses NSJSONSerialisation.
 */
+ (id<PTJSONParser>)JSONParser;

@end
