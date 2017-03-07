//
//  PTJSON.h
//  libPusher
//
//  Created by Luke Redpath on 30/03/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PTJSONParser <NSObject>

- (NSData * _Nullable)JSONDataFromObject:(id _Nullable)object;
- (NSString * _Nullable)JSONStringFromObject:(id _Nullable)object;
- (id _Nullable)objectFromJSONData:(NSData * _Nullable)data parseError:(nullable void (^)(NSError * _Nullable error))parseError;
- (id _Nullable)objectFromJSONString:(NSString * _Nullable)string parseError:(nullable void (^)(NSError * _Nullable error))parseError;

@end

@interface PTJSON : NSObject

/**
 Returns a JSON parser appropriate for the current platform.
 
 As of libPusher 1.5, the lowest supported deployment target is iOS 5.0
 so this will always return a parser that uses NSJSONSerialisation.
 */
+ (id <PTJSONParser> _Nullable)JSONParser;

@end
