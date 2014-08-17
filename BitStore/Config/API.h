//
//  API.h
//  BitStore
//
//  Created by Dylan Marriott on 04.08.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface API : NSObject

+ (NSString *)settingsUrl;
+ (NSString *)analyticsUrl;
+ (NSString *)changeUnitUrl;
+ (NSString *)createOrderUrl;
+ (NSString *)createCustomerUrl;
+ (NSString *)doOrderUrl;
+ (NSString *)registerPushUrl;
+ (NSString *)unregisterPushUrl;

@end
