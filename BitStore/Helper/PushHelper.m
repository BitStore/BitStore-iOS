//
//  PushHelper.m
//  BitStore
//
//  Created by Dylan Marriott on 06.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "PushHelper.h"
#import "JobHelper.h"
#import "Job.h"
#import "UserDefaults.h"
#import "Address.h"
#import "AddressHelper.h"
#import "ExchangeHelper.h"
#import "Unit.h"

@implementation PushHelper

+ (void)registerPush:(NSString *)token {
    Address* address = [AddressHelper instance].defaultAddress;
    NSLog(@"push register: %@", address.address);
    NSString* lang = [[NSLocale preferredLanguages] objectAtIndex:0];
    Unit* unit = [[ExchangeHelper instance] currentUnit];
    NSString* url = [NSString stringWithFormat:@"%@?a=%@&t=%@&l=%@&u=%@", [API registerPushUrl], address.address, token, lang, unit.technicalName];
    [[JobHelper instance] postJob:[[Job alloc] initWithUrl:url]];
}

+ (void)unregister {
    Address* address = [AddressHelper instance].defaultAddress;
    [self unregister:address.address];
}

+ (void)unregister:(NSString *)address {
    NSLog(@"push unregister: %@", address);
    NSString* url = [NSString stringWithFormat:@"%@?a=%@", [API unregisterPushUrl], address];
    [[JobHelper instance] postJob:[[Job alloc] initWithUrl:url]];
}

@end
