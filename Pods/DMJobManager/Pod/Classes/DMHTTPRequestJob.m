//
//  DMHTTPRequestJob.m
//  Pods
//
//  Created by Dylan Marriott on 03/11/14.
//
//

#import "DMHTTPRequestJob.h"

@implementation DMHTTPRequestJob {
    NSString* _url;
    NSData* _postData;
}

- (instancetype)initWithUrl:(NSString *)url {
    return [self initWithUrl:url postData:nil];
}

- (instancetype)initWithUrl:(NSString *)url postData:(NSData *)postData {
    if (self = [super init]) {
        _url = url;
        _postData = postData;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _url = [aDecoder decodeObjectForKey:@"url"];
        _postData = [aDecoder decodeObjectForKey:@"postData"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_url forKey:@"url"];
    [aCoder encodeObject:_postData forKey:@"postData"];
}

- (void)executeWithCompletion:(CompletionBlock)completion {
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_url]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if (_postData) {
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:_postData];
    }
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse* response,
                                               NSData* data,
                                               NSError* error) {
                               NSLog(@"Reqest completed, error: %@", error);
                               completion(!error);
                           }];
}

- (NSTimeInterval)retryDelay {
    return 30;
}

@end
