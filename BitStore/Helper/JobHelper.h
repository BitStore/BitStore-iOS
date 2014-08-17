//
//  JobHelper.h
//  BitStore
//
//  Created by Dylan Marriott on 20.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Job;

@interface JobHelper : NSObject

+ (JobHelper *)instance;

- (void)postJob:(Job *)job;

@end
