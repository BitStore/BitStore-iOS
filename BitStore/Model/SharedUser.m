//
//  SharedUser.m
//  BitStore
//
//  Created by Dylan Marriott on 23/09/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "SharedUser.h"
#import "UserDefaults.h"

@implementation SharedUser {
    NSUserDefaults* _defaults;
}

- (id)init {
    if (self = [super init]) {
        _defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.bitstore"];
    }
    return self;
}

- (NSString *)todayCurrency {
    NSString* ret = [_defaults stringForKey:@"todayCurrency"];
    if (!ret) {
        ret = @"USD";
        [self setTodayCurrency:ret];
    }
    return ret;
}

- (void)setTodayCurrency:(NSString *)todayCurrency {
    [_defaults setObject:todayCurrency forKey:@"todayCurrency"];
    [_defaults synchronize];
}

- (NSNumber *)cachedPrice {
    return [_defaults objectForKey:@"cachedPrice"];
}

- (void)setCachedPrice:(NSNumber *)cachedPrice {
    [_defaults setObject:cachedPrice forKey:@"cachedPrice"];
    [_defaults synchronize];
}

- (NSString *)address {
    return [_defaults objectForKey:@"address"];
}

- (void)setAddress:(NSString *)address {
    [_defaults setObject:address forKey:@"address"];
    [_defaults synchronize];
}

@end
