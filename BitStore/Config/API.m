//
//  API.m
//  BitStore
//
//  Created by Dylan Marriott on 04.08.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "API.h"

@implementation API

+ (NSString *)settingsUrl {
    return [NSString stringWithFormat:@"%@/settings.php", [self baseUrl]];
}

+ (NSString *)analyticsUrl {
    return [NSString stringWithFormat:@"%@/analytics/", [self baseUrl]];
}

+ (NSString *)changeUnitUrl {
    return [NSString stringWithFormat:@"%@/change_unit.php", [self baseUrl]];
}

+ (NSString *)createOrderUrl {
    return [NSString stringWithFormat:@"%@/create_order.php", [self baseUrl]];
}

+ (NSString *)createCustomerUrl {
    return [NSString stringWithFormat:@"%@/create_customer.php", [self baseUrl]];
}

+ (NSString *)doOrderUrl {
    return [NSString stringWithFormat:@"%@/do_order.php", [self baseUrl]];
}

+ (NSString *)registerPushUrl {
    return [NSString stringWithFormat:@"%@/register.php", [self baseUrl]];
}

+ (NSString *)unregisterPushUrl {
    return [NSString stringWithFormat:@"%@/unregister.php", [self baseUrl]];
}

+ (NSString *)baseUrl {
    if ([[Environment environment] isEqualToString:@"TEST"]) {
        return @"http://test.bitstoreapp.com/api";
    } else {
        return @"https://bitstoreapp.com/api";
    }
}

+ (NSString *)ringCaptchaAppKey {
#warning TODO implement a clever way to get the API keys
    // ringCaptcha isn't used atm
    return @"";
}

+ (NSString *)ringCaptchaAPIKey {
    return @"";
}

@end
