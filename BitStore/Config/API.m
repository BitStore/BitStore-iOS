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
    return [NSString stringWithFormat:@"%@/api/settings.php", [self baseUrl]];
}

+ (NSString *)analyticsUrl {
    return [NSString stringWithFormat:@"%@/analytics/", [self baseUrl]];
}

+ (NSString *)changeUnitUrl {
    return [NSString stringWithFormat:@"%@/api/change_unit.php", [self baseUrl]];
}

+ (NSString *)createOrderUrl {
    return [NSString stringWithFormat:@"%@/api/create_order.php", [self baseUrl]];
}

+ (NSString *)createCustomerUrl {
    return [NSString stringWithFormat:@"%@/api/create_customer.php", [self baseUrl]];
}

+ (NSString *)doOrderUrl {
    return [NSString stringWithFormat:@"%@/api/do_order.php", [self baseUrl]];
}

+ (NSString *)registerPushUrl {
    return [NSString stringWithFormat:@"%@/api/register.php", [self baseUrl]];
}

+ (NSString *)unregisterPushUrl {
    return [NSString stringWithFormat:@"%@/api/unregister.php", [self baseUrl]];
}

+ (NSString *)baseUrl {
    if ([[Environment environment] isEqualToString:@"TEST"]) {
        return @"http://test.bitstoreapp.com";
    } else {
        return @"https://bitstoreapp.com";
    }
}

@end
