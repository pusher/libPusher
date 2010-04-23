//
//  NSURL+StringFormat.m
//  libPusher
//
//  Created by Luke Redpath on 23/04/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "NSURL+StringFormat.h"


@implementation NSURL (StringFormat)

+ (id)URLWithFormat:(NSString *)formatString, ...
{
  va_list args;
  va_start(args, formatString);
  NSString *string = [NSString stringWithFormat:formatString, args];
  va_end(args);
  
  return [NSURL URLWithString:string];
}

@end
