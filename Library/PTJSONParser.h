//
//  PTJSONParser.h
//  libPusher
//
//  Created by Luke Redpath on 30/03/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PTJSONParser <NSObject>

- (NSData *)JSONDataFromObject:(id)object;
- (id)objectFromJSONData:(NSData *)data;
- (id)objectFromJSONString:(NSString *)string;

@end
