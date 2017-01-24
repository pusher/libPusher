//
//  LRURLConnectionOperation.m
//  LRResty
//
//  Created by Luke Redpath on 04/10/2010.
//  Copyright 2010 LJR Software Limited. All rights reserved.
//

#import "PTURLRequestOperation.h"

@interface PTURLRequestOperationURLSessionDelegate : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (nonatomic, weak, readwrite) id<NSURLSessionDelegate, NSURLSessionDataDelegate> delegate;

@end

@implementation PTURLRequestOperationURLSessionDelegate

#pragma mark -
#pragma mark NSURLSessionDelegate methods

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
  [self.delegate URLSession:session dataTask:dataTask didReceiveData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
  [self.delegate URLSession:session task:task didCompleteWithError:error];
}

#pragma mark -
#pragma mark NSURLSessionDataDelegate methods

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
  [self.delegate URLSession:session dataTask:dataTask didReceiveResponse:response completionHandler:completionHandler];
}

@end

@interface PTURLRequestOperation ()
@property (nonatomic, strong, readwrite) NSURLResponse *URLResponse;
@property (nonatomic, strong, readwrite) NSError *connectionError;
@property (nonatomic, strong, readwrite) NSData *responseData;
@property (nonatomic, strong, readwrite) PTURLRequestOperationURLSessionDelegate *sessionDelegate;

- (void)setExecuting:(BOOL)isExecuting;
- (void)setFinished:(BOOL)isFinished;
@end

#pragma mark -

@implementation PTURLRequestOperation

@synthesize URLRequest;
@synthesize URLResponse;
@synthesize connectionError;
@synthesize responseData;

- (instancetype)initWithURLRequest:(NSURLRequest *)request;
{
  if ((self = [super init])) {
    URLRequest = request;
  }
  return self;
}


- (void)start
{
  NSAssert(URLRequest, @"Cannot start URLRequestOperation without a NSURLRequest.");

  if (![NSThread isMainThread]) {
    return [self performSelector:@selector(start) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
  }

  if ([self isCancelled]) {
    [self finish];
    return;
  }

  [self setExecuting:YES];

  self.sessionDelegate = [PTURLRequestOperationURLSessionDelegate new];
  self.sessionDelegate.delegate = self;
  NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
  _URLSession = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self.sessionDelegate delegateQueue:nil];
  NSURLSessionDataTask *task = [_URLSession dataTaskWithRequest:URLRequest];

  if (_URLSession == nil) {
    [self setFinished:YES];
  }

  [task resume];
}

- (void)finish
{
  [_URLSession invalidateAndCancel];
  if (self.isExecuting) {
    [self setExecuting:NO];
    [self setFinished:YES];
  }
}

- (BOOL)isConcurrent
{
  return YES;
}

- (BOOL)isExecuting
{
  return _isExecuting;
}

- (BOOL)isFinished
{
  return _isFinished;
}

#pragma mark -
#pragma mark NSURLSessionDelegate methods

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
  if (self.responseData == nil) { // this might be called before didReceiveResponse
    self.responseData = [NSMutableData data];
  }

  [responseData appendData:data];

  [self checkForCancellation];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
  self.connectionError = error;
  [self finish];
}

- (void)cancelImmediately
{
  [self finish];
}

- (void)checkForCancellation
{
  if ([self isCancelled]) {
    [self cancelImmediately];
  }
}

#pragma mark -
#pragma mark NSURLSessionDataDelegate methods

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
  self.URLResponse = response;
  self.responseData = [NSMutableData data];
  completionHandler(NSURLSessionResponseAllow);
}

#pragma mark -
#pragma mark Private methods

- (void)setExecuting:(BOOL)isExecuting;
{
  if (_isExecuting != isExecuting)
  {
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = isExecuting;
    [self didChangeValueForKey:@"isExecuting"];
  }
}

- (void)setFinished:(BOOL)isFinished;
{
  if (_isFinished != isFinished)
  {
    [self willChangeValueForKey:@"isFinished"];
    [self setExecuting:NO];
    _isFinished = isFinished;
    [self didChangeValueForKey:@"isFinished"];
  }
}

@end
