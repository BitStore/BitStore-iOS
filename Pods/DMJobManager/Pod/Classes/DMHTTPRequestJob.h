//
//  DMHTTPRequestJob.h
//  Pods
//
//  Created by Dylan Marriott on 03/11/14.
//
//

#import <Foundation/Foundation.h>
#import "DMJob.h"

@interface DMHTTPRequestJob : NSObject <DMJob>

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithUrl:(NSString *)url;
- (instancetype)initWithUrl:(NSString *)url postData:(NSData *)postData;

@end
