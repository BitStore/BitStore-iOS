//
//  Keys.h
//  BitStore
//
//  Created by Dylan Marriott on 17.08.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Keys : NSObject

+ (NSString *)chainKey;
+ (NSString *)ringCaptchaAppKey;
+ (NSString *)ringCaptchaAPIKey;
+ (NSString *)analyticsKey;
+ (NSString *)stripeTestKey;
+ (NSString *)stripeProductionKey;

@end
