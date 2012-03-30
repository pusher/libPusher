//
//  PTJSON.h
//  libPusher
//
//  Created by Luke Redpath on 30/03/2012.
//  Copyright (c) 2012 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PTJSONParser.h"

extern NSString *const PTJSONParserNotAvailable;

@interface PTJSON : NSObject

/**
 Returns a JSON parser appropriate for the current platform.
 
 A runtime check is performed for the presence of NSJSONSerialization
 (available on iOS 5.0 and OSX 10.7 and later). If it is available,
 it will be used, otherwise it will fall back to using JSONKit.
 
 Important note: If you intend to support users of iOS 4.x, you must
 ensure that you link JSONKit to your project as it is no longer
 embedded within libPusher.
 */
+ (id<PTJSONParser>)JSONParser;

@end

@interface PTJSONKitParser : NSObject <PTJSONParser>
+ (id)JSONKitParser;
@end

@interface PTNSJSONParser : NSObject <PTJSONParser>
+ (id)NSJSONParser;
@end