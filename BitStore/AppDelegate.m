//
//  AppDelegate.m
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "AppDelegate.h"
#import "PushHelper.h"
#import "UserDefaults.h"
#import "AddressHelper.h"
#import "Address.h"
#import "URI.h"
#import "SendNavigationController.h"
#import "ReceiveNavigationController.h"
#import "AppStart.h"
#import <DMJobManager/DMJobManager.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    [DMJobManager startManager];
    [AppStart start];
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
    [AppStart loadSettings];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    BOOL opened = NO;
    if ([url.scheme isEqualToString:@"bitcoin"]) {
        URI* uri = [[URI alloc] initWithString:url.description];
        SendNavigationController* vc = [[SendNavigationController alloc] initWithAddress:uri.address amount:uri.amount];
        [self.window.rootViewController presentViewController:vc animated:YES completion:nil];
        opened = YES;
    } else if ([url.scheme isEqualToString:@"bitstore"]) {
        if ([url.lastPathComponent isEqualToString:@"send"]) {
            SendNavigationController* vc = [[SendNavigationController alloc] init];
            [self.window.rootViewController presentViewController:vc animated:YES completion:nil];
            opened = YES;
        } else if ([url.lastPathComponent isEqualToString:@"receive"]) {
            ReceiveNavigationController* vc = [[ReceiveNavigationController alloc] init];
            [self.window.rootViewController presentViewController:vc animated:YES completion:nil];
            opened = YES;
        }
    }
    return opened;
}

@end
