//
//  MainViewControllerPhone.m
//  BitStore
//
//  Created by Dylan Marriott on 18.08.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "MainViewControllerPhone.h"
#import "AccountNavigationController.h"
#import "SendNavigationController.h"
#import "ContactsNavigationController.h"
#import "ShopsNavigationController.h"
#import "SettingsNavigationController.h"

@implementation MainViewControllerPhone

- (id)init {
	if (self = [super init]) {
	    AccountNavigationController* accountNavigationController = [[AccountNavigationController alloc] init];
		accountNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:accountNavigationController.title image:[UIImage imageNamed:@"male"] selectedImage:[UIImage imageNamed:@"male_selected"]];
		
		ContactsNavigationController* contactsNavigationController = [[ContactsNavigationController alloc] init];
		contactsNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:contactsNavigationController.title image:[UIImage imageNamed:@"contacts"] selectedImage:[UIImage imageNamed:@"contacts_selected"]];
		
		ShopsNavigationController* shopsNavigationController = [[ShopsNavigationController alloc] init];
		shopsNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:shopsNavigationController.title image:[UIImage imageNamed:@"store"] selectedImage:[UIImage imageNamed:@"store_selected"]];
		
		SettingsNavigationController* settingsNavigationController = [[SettingsNavigationController alloc] init];
		settingsNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:settingsNavigationController.title image:[UIImage imageNamed:@"settings"] selectedImage:[UIImage imageNamed:@"settings_selected"]];
		
		[self setViewControllers:[NSArray arrayWithObjects:accountNavigationController, contactsNavigationController, settingsNavigationController, nil]];
	}
	return self;
}

@end
