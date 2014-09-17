//
//  UserDefaults.m
//  BitStore
//
//  Created by Dylan Marriott on 04.02.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "UserDefaults.h"
#import "Exchange.h"
#import "Address.h"
#import "ContactList.h"

@implementation UserDefaults {
    NSUserDefaults* _defaults;
}

static UserDefaults* sharedInstance;

+ (void)initialize {
    [super initialize];
    sharedInstance = [[UserDefaults alloc] init];
}

+ (UserDefaults *)instance {
    return sharedInstance;
}

- (id)init {
	if (self = [super init]) {
		_defaults = [NSUserDefaults standardUserDefaults];
	}
	return self;
}

#pragma mark - Public

// Exchange
- (Exchange *)exchange {
	return (Exchange *)[self codableObjectForKey:@"exchange"];
}

- (void)setExchange:(Exchange *)exchange {
	[self setCodableObject:exchange forKey:@"exchange"];
}

// Addresses
- (NSArray *)addresses {
	return (NSArray *)[self codableObjectForKey:@"addresses_2"];
}

- (void)setAddresses:(NSArray *)addresses {
	[self setCodableObject:addresses forKey:@"addresses_2"];
}

// Default Address Index
- (NSInteger)defaultAddressIndex {
    return [_defaults integerForKey:@"defaultAddressIndex"];
}

- (void)setDefaultAddressIndex:(NSInteger)defaultAddressIndex {
    [_defaults setInteger:defaultAddressIndex forKey:@"defaultAddressIndex"];
    [_defaults synchronize];
}

// ContactList
- (ContactList *)contactList {
	return (ContactList *)[self codableObjectForKey:@"contactList"];
}

- (void)setContactList:(ContactList *)contactList {
	[self setCodableObject:contactList forKey:@"contactList"];
}

// Version
- (NSInteger)version {
    return [_defaults integerForKey:@"version"];
}

- (void)setVersion:(NSInteger)version {
    [_defaults setInteger:version forKey:@"version"];
    [_defaults synchronize];
}

// PushActive
- (BOOL)pushActive {
    return [_defaults boolForKey:@"pushActive"];
}

- (void)setPushActive:(BOOL)pushActive {
    [_defaults setBool:pushActive forKey:@"pushActive"];
    [_defaults synchronize];
}

// DefaultPayMode
- (NSInteger)defaultPayMode {
    return [_defaults integerForKey:@"defaultPayMode"];
}

- (void)setDefaultPayMode:(NSInteger)defaultPayMode {
    [_defaults setInteger:defaultPayMode forKey:@"defaultPayMode"];
    [_defaults synchronize];
}

// TX Cache
- (NSMutableDictionary *)txcache {
    return (NSMutableDictionary *)[self codableObjectForKey:@"txcache"];
}

- (void)setTxcache:(NSMutableDictionary *)txcache {
    [self setCodableObject:txcache forKey:@"txcache"];
}

// Jobs
- (NSArray *)jobs {
    return (NSArray *)[self codableObjectForKey:@"jobs"];
}

- (void)setJobs:(NSArray *)jobs {
    [self setCodableObject:jobs forKey:@"jobs"];
}

// UserId
- (NSString *)userId {
    return [_defaults stringForKey:@"userId"];
}

- (void)setUserId:(NSString *)userId {
    [_defaults setObject:userId forKey:@"userId"];
    [_defaults synchronize];
}

// Buy enabled
- (BOOL)buyEnabled {
    return [_defaults boolForKey:@"buyEnabled"];
}

- (void)setBuyEnabled:(BOOL)buyEnabled {
    [_defaults setBool:buyEnabled forKey:@"buyEnabled"];
    [_defaults synchronize];
}

// Buy showed
- (BOOL)buyShowed {
    return [_defaults boolForKey:@"buyShowed"];
}

- (void)setBuyShowed:(BOOL)buyShowed {
    [_defaults setBool:buyShowed forKey:@"buyShowed"];
    [_defaults synchronize];
}

// Buy dismissed
- (BOOL)buyDismissed {
    return [_defaults boolForKey:@"buyDismissed"];
}

- (void)setBuyDismissed:(BOOL)buyDismissed {
    [_defaults setBool:buyDismissed forKey:@"buyDismissed"];
    [_defaults synchronize];
}

// CustomerId
- (NSString *)customerId {
    return [_defaults stringForKey:@"customerId"];
}

- (void)setCustomerId:(NSString *)customerId {
    [_defaults setObject:customerId forKey:@"customerId"];
    [_defaults synchronize];
}

#pragma mark -
- (void)reset {
	NSString* domain = [[NSBundle mainBundle] bundleIdentifier];
	[_defaults removePersistentDomainForName:domain];
}


#pragma mark - Private
- (void)setCodableObject:(id<NSCoding>)object forKey:(NSString *)key {
	NSData* encoded = [NSKeyedArchiver archivedDataWithRootObject:object];
	[_defaults setObject:encoded forKey:key];
	[_defaults synchronize];
}

- (id<NSCoding>)codableObjectForKey:(NSString *)key {
	NSData* encoded = [_defaults objectForKey:key];
	id<NSCoding> ret = [NSKeyedUnarchiver unarchiveObjectWithData:encoded];
	return ret;
}

@end
