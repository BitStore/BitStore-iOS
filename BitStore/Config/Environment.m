//
//  Environment.m
//  BitStore
//
//  Created by Dylan Marriott on 05.08.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "Environment.h"

@implementation Environment

+ (NSString *)environment {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"RunningEnvironment"];
}

@end
