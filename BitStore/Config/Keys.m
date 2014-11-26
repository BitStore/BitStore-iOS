//
//  Keys.m
//  BitStore
//
//  Created by Dylan Marriott on 17.08.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "Keys.h"

@implementation Keys

+ (NSString *)chainKey {
    return @"fd231d38cbc484a9ca05005d5c9477c2";
}

+ (NSString *)ringCaptchaAppKey {
    return @"i1ohi2o3o6uja2iqoqiq";
}

+ (NSString *)ringCaptchaAPIKey {
    return @"75dc2a6ce4668f08fbae3482bdf6b9582d7f378d";
}

+ (NSString *)analyticsKey {
    return @"6ad579d388160736086a9190cc5ff133";
}

+ (NSString *)stripeTestKey {
    return @"pk_test_4SpT6lRqwpbCMhV1nMinAUaC";
}

+ (NSString *)stripeProductionKey {
    return @"pk_live_4SpTDVMx4YrqpZKvP8mF6Seq";
}

@end
