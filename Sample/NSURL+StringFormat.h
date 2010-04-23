//
//  NSURL+StringFormat.h
//  libPusher
//
//  Created by Luke Redpath on 23/04/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSURL (StringFormat)
+ (id)URLWithFormat:(NSString *)formatString, ...;
@end
