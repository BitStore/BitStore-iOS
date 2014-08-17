//
//  SettingsNavigationController.m
//  BitStore
//
//  Created by Dylan Marriott on 30.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "SettingsNavigationController.h"
#import "SettingsViewController.h"

@implementation SettingsNavigationController

- (id)init {
    if (self = [super init]) {
	    SettingsViewController* vc = [[SettingsViewController alloc] init];
		self.title = vc.title;
		[self pushViewController:vc animated:NO];
	}
    return self;
}

@end
