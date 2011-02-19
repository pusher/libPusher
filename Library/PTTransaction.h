//
//  PTTransaction.h
//  Cloud
//
//  Created by Nick Paulson on 2/19/11.
//  Copyright 2011 Linebreak. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PTTransaction : NSObject {
	NSURLRequest *_request;
	NSURLConnection *_connection;
	NSMutableData *_receivedData;
	NSHTTPURLResponse *_response;
	NSString *_identifier;
	id _userInfo;
}

@property (nonatomic, readwrite, retain) NSURLRequest *request;
@property (nonatomic, readwrite, retain) NSHTTPURLResponse *response;
@property (nonatomic, readwrite, retain) NSURLConnection *connection;
@property (nonatomic, readwrite, retain) NSMutableData *receivedData;
@property (nonatomic, readwrite, copy) NSString *identifier;
@property (nonatomic, readwrite, retain) id userInfo;

+ (id)transaction;

@end
