//
//  PushHelper.h
//  BitStore
//
//  Created by Dylan Marriott on 06.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushHelper : NSObject

+ (void)registerPush:(NSString *)token;
+ (void)unregister;
+ (void)unregister:(NSString *)address;

@end
