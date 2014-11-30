//
//  AppStart.m
//  BitStore
//
//  Created by Dylan Marriott on 18.08.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "AppStart.h"
#import "UserDefaults.h"
#import "Lockbox.h"
#import "Address.h"
#import "AddressHelper.h"
#import <iRate/iRate.h>
#import "AppDelegate.h"
#import "RequestHelper.h"
#import "MainViewControllerPhone.h"
#import "SharedUser.h"
//#import "SDStatusBarManager.h"

@implementation AppStart

+ (void)start {
    [self migrate];
    [self setupStorage];
    [self setupKeychain];
    [self setupRate];
    [self setupAnalytics];
	[self setupViewController];
    //[[SDStatusBarManager sharedInstance] enableOverrides];
}

+ (void)migrate {
    NSInteger version = [UserDefaults instance].version;
    if (version == 0) {
        // we changed some stuff in the user defaults from v1 (0) to v1.1 (1)
        [[UserDefaults instance] reset];
    } else if (version <= 2) {
        NSDictionary* oldKey1 = [Lockbox dictionaryForKey:@"bitstore" sync:YES]; // v1.0 & v1.1
        NSDictionary* oldKey2 = [Lockbox dictionaryForKey:@"bitstore_2"]; // v1.2
        
        NSString* key = nil;
        if (oldKey1 != nil) {
            key = [oldKey1 objectForKey:@"private"];
        }
        
        if (key == nil && oldKey2 != nil) {
            key = [oldKey2 objectForKey:@"private"];
        }
        
        if (key != nil) {
            [Lockbox setArray:[NSArray arrayWithObject:key] forKey:@"bitstore_3"];
        }
    }
    [UserDefaults instance].version = 4;
}

+ (void)setupStorage {
    if ([UserDefaults instance].txcache == nil) {
        [UserDefaults instance].txcache = [[NSMutableDictionary alloc] init];
    }
    
    if ([UserDefaults instance].userId == nil) {
        [UserDefaults instance].userId = [[NSUUID UUID] UUIDString];
    }
}

+ (void)setupKeychain {
	//    [UserDefaults instance].buyDismissed = NO;
	//    [UserDefaults instance].buyShowed = NO;
	//    [UserDefaults instance].addresses = nil;
    
	if ([[AddressHelper instance] defaultAddress] == nil) {
        
        NSArray* keys = [Lockbox arrayForKey:@"bitstore_3"];
        
        NSString* publicKey;
        NSString* privateKey;
        
        if (keys == nil) {
            BTCKey* k = [[BTCKey alloc] init];
            publicKey = k.uncompressedPublicKeyAddress.base58String;
            privateKey = k.privateKeyAddress.base58String;
            
            [Lockbox setArray:[NSArray arrayWithObject:privateKey] forKey:@"bitstore_3"];
        } else {
            privateKey = [keys objectAtIndex:0];
            BTCKey* k = [[BTCKey alloc] initWithPrivateKeyAddress:[BTCPrivateKeyAddress addressWithBase58String:privateKey]];
            publicKey = k.uncompressedPublicKeyAddress.base58String;
        }
		
		Address* address = [[Address alloc] init];
		address.address = publicKey;
        [[AddressHelper instance] addAddress:address];
	}
    
    
    // for today widget
    SharedUser* sharedUser = [[SharedUser alloc] init];
    if (sharedUser.address == nil) {
        sharedUser.address = [AddressHelper instance].defaultAddress.address;
    }
}

+ (void)setupRate {
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].daysUntilPrompt = 10;
}

+ (void)setupAnalytics {
    BitStoreKeys* keys = [[BitStoreKeys alloc] init];
    NSString* url = [API analyticsUrl];
    [PiwikTracker sharedInstanceWithBaseURL:[NSURL URLWithString:url] siteID:@"2" authenticationToken:keys.analytics];
    [PiwikTracker sharedInstance].dispatchInterval = 30;
}

+ (void)setupViewController {
    [[UITabBar appearance] setTintColor:[Color mainTintColor]];
    [[UINavigationBar appearance] setTintColor:[Color mainTintColor]];
	MainViewControllerPhone* vc = [[MainViewControllerPhone alloc] init];
	((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController = vc;
}

+ (void)loadSettings {
	Address* address = [AddressHelper instance].defaultAddress;
	NSString* url = [NSString stringWithFormat:@"%@?v=%li&a=%@", [API settingsUrl], (long)[UserDefaults instance].version, address.address];
    RequestHelper* rh = [[RequestHelper alloc] init];
	[rh startRequestWithUrl:url completion:^(BOOL success, NSData* data) {
		if (success) {
			NSError* error;
			NSDictionary* settings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
			if (!error) {
				[UserDefaults instance].buyEnabled = ((NSString *)[settings objectForKey:@"buyEnabled"]).boolValue;
				[UserDefaults instance].pushActive = ((NSString *)[settings objectForKey:@"pushEnabled"]).boolValue;
			}
		} else {
			// try again in 15s
			[self performSelector:@selector(loadSettings) withObject:nil afterDelay:15];
		}
	}];
}

@end
