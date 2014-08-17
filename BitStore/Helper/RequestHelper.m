//
//  RequestHelper.m
//  BitStore
//
//  Created by Dylan Marriott on 02/02/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "RequestHelper.h"

static RequestHelper* instance;

@interface RequestHelper () <NSURLConnectionDataDelegate>

@end

@implementation RequestHelper {
	SingleCompletionBlock _singleCompletionBlock;
	MultipleCompletionBlock _multipleCompletionBlock;
    NSMutableData* _currentData;
	NSMutableArray* _queue;
	NSMutableArray* _data;
}

- (void)startRequestWithUrl:(NSString *)url completion:(SingleCompletionBlock)completion {
	_singleCompletionBlock = completion;
	_multipleCompletionBlock = nil;
	_queue = [[NSMutableArray alloc] initWithObjects:url, nil];
	[self start];
}

- (void)startRequestWithUrls:(NSArray *)urls completion:(MultipleCompletionBlock)completion {
	_singleCompletionBlock = nil;
	_multipleCompletionBlock = completion;
	_queue = [[NSMutableArray alloc] initWithArray:urls];
	[self start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [_currentData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_currentData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self finishedRequest];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self finishWithSuccess:NO data:nil];
}

- (void)start {
	if (_data == nil) {
		_data = [[NSMutableArray alloc] init];
	}
	
	NSString* url = [_queue firstObject];
	[_queue removeObjectAtIndex:0];
	
	//NSLog(@"RequestHelper: %@", url);
	
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    _currentData = [NSMutableData dataWithCapacity: 0];
    NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!connection) {
        _currentData = nil;
		[self finishWithSuccess:NO data:nil];
    }
}

- (void)finishedRequest {
	[_data addObject:_currentData];
	_currentData = nil;
	if (_queue.count == 0) {
		if (_singleCompletionBlock) {
			[self finishWithSuccess:YES data:[_data firstObject]];
		} else if (_multipleCompletionBlock) {
			[self finishWithSuccess:YES data:_data];
		}
	} else {
		[self start];
	}
}

- (void)finishWithSuccess:(BOOL)success data:(id)data {
	if (_singleCompletionBlock) {
		_singleCompletionBlock(success, data);
	}
	if (_multipleCompletionBlock) {
		_multipleCompletionBlock(success, data);
	}
}

@end
