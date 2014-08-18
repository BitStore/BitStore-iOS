//
//  AppDelegate.m
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "AppDelegate.h"
#import "AccountNavigationController.h"
#import "Address.h"
#import "SendNavigationController.h"
#import "ContactsNavigationController.h"
#import "ShopsNavigationController.h"
#import "SettingsNavigationController.h"
#import "Lockbox.h"
#import "UserDefaults.h"
#import "iRate.h"
#import "PushHelper.h"
#import "iOSFix.h"
#import "AddressHelper.h"
#import "RequestHelper.h"
#import "URI.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self migrate];
    [self setupStorage];
    [self setupKeychain];
    [self setupRate];
    [self setupAnalytics];
	[self setupWindow];
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    NSString* token = [deviceToken description];
	token = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    [PushHelper registerPush:token];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    Address* address = [AddressHelper instance].defaultAddress;
    [address refresh];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
	[UserDefaults instance].pushActive = NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    Address* address = [AddressHelper instance].defaultAddress;
    [address refresh];
	[self loadSettings];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    URI* uri = [[URI alloc] initWithString:url.description];
    SendNavigationController* vc = [[SendNavigationController alloc] initWithAddress:uri.address amount:uri.amount];
    [self.window.rootViewController presentViewController:vc animated:YES completion:nil];
	return YES;
}

- (void)loadSettings {
	Address* address = [AddressHelper instance].defaultAddress;
	NSString* url = [NSString stringWithFormat:@"%@?v=%i&a=%@", [API settingsUrl], [UserDefaults instance].version, address.address];
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

- (void)migrate {
    int version = [UserDefaults instance].version;
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

- (void)setupStorage {
    if ([UserDefaults instance].txcache == nil) {
        [UserDefaults instance].txcache = [[NSMutableDictionary alloc] init];
    }
    
    if ([UserDefaults instance].userId == nil) {
        [UserDefaults instance].userId = [[NSUUID UUID] UUIDString];
    }
}

- (void)setupKeychain {
//    [UserDefaults instance].buyDismissed = NO;
//    [UserDefaults instance].buyShowed = NO;
//    [UserDefaults instance].addresses = nil;
    
	if ([[AddressHelper instance] defaultAddress] == nil) {
        
        NSArray* keys = [Lockbox arrayForKey:@"bitstore_3"];
        
        NSString* publicKey;
        NSString* privateKey;
        
        if (keys == nil) {
            BTCKey* k = [[BTCKey alloc] init];
            publicKey = k.publicKeyAddress.base58String;
            privateKey = k.privateKeyAddress.base58String;
            
            [Lockbox setArray:[NSArray arrayWithObject:privateKey] forKey:@"bitstore_3"];
        } else {
            privateKey = [keys objectAtIndex:0];
            BTCKey* k = [[BTCKey alloc] initWithPrivateKeyAddress:[BTCPrivateKeyAddress addressWithBase58String:privateKey]];
            publicKey = k.publicKeyAddress.base58String;
        }
		
		Address* address = [[Address alloc] init];
		address.address = publicKey;
        [[AddressHelper instance] addAddress:address];
	}
}

- (void)setupRate {
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].daysUntilPrompt = 10;
}

- (void)setupAnalytics {
    NSString* url = [API analyticsUrl];
    [PiwikTracker sharedInstanceWithBaseURL:[NSURL URLWithString:url] siteID:@"2" authenticationToken:[Keys analyticsKey]];
    [PiwikTracker sharedInstance].dispatchInterval = 30;
}

- (void)setupWindow {
    AccountNavigationController* accountNavigationController = [[AccountNavigationController alloc] init];
    accountNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:accountNavigationController.title image:[UIImage imageNamed:@"male"] selectedImage:[UIImage imageNamed:@"male_selected"]];
    
    ContactsNavigationController* contactsNavigationController = [[ContactsNavigationController alloc] init];
    contactsNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:contactsNavigationController.title image:[UIImage imageNamed:@"contacts"] selectedImage:[UIImage imageNamed:@"contacts_selected"]];
    
    ShopsNavigationController* shopsNavigationController = [[ShopsNavigationController alloc] init];
    shopsNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:shopsNavigationController.title image:[UIImage imageNamed:@"store"] selectedImage:[UIImage imageNamed:@"store_selected"]];
    
	SettingsNavigationController* settingsNavigationController = [[SettingsNavigationController alloc] init];
	settingsNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:settingsNavigationController.title image:[UIImage imageNamed:@"settings"] selectedImage:[UIImage imageNamed:@"settings_selected"]];
	
    UITabBarController* tbc = [[UITabBarController alloc] init];
    [tbc setViewControllers:[NSArray arrayWithObjects:accountNavigationController, contactsNavigationController, settingsNavigationController, nil]];
    
    [[UITabBar appearance] setTintColor:[Color mainTintColor]];
    [[UINavigationBar appearance] setTintColor:[Color mainTintColor]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
	self.window.rootViewController = tbc;
    [self.window makeKeyAndVisible];
}

@end
