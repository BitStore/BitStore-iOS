//
//  RequestHelper.h
//  BitStore
//
//  Created by Dylan Marriott on 02/02/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SingleCompletionBlock)(BOOL, NSData *);
typedef void (^MultipleCompletionBlock)(BOOL, NSArray *);

@interface RequestHelper : NSObject

- (void)startRequestWithUrl:(NSString *)url completion:(SingleCompletionBlock)completion;
- (void)startRequestWithUrls:(NSArray *)urls completion:(MultipleCompletionBlock)completion;

@end
