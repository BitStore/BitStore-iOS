//
//  ContactsNavigationController.m
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "ContactsNavigationController.h"
#import "ContactsViewController.h"

@implementation ContactsNavigationController

- (id)init {
    if (self = [super init]) {
		ContactsViewController* vc = [[ContactsViewController alloc] init];
		self.title = vc.title;
		[self pushViewController:vc animated:NO];
	}
    return self;
}

@end
