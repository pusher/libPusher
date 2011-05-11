//
//  PTTransaction.m
//  Cloud
//
//  Created by Nick Paulson on 2/19/11.
//  Copyright 2011 Linebreak. All rights reserved.
//

#import "PTTransaction.h"


@implementation PTTransaction

@synthesize request = _request, connection = _connection, receivedData = _receivedData, 
userInfo = _userInfo, identifier = _identifier, response = _response;

- (id)init {
	if ((self = [super init])) {
		self.receivedData = [NSMutableData data];
	}
	return self;
}

+ (id)transaction {
	return [[[[self class] alloc] init] autorelease];
}

- (void)dealloc {
    self.request = nil;
	self.response = nil;
    self.connection = nil;
    self.receivedData = nil;
    self.userInfo = nil;
	self.identifier = nil;
	
    [super dealloc];
}


@end
