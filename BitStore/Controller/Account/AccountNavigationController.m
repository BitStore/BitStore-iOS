//
//  AccountNavigationController.m
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "AccountNavigationController.h"
#import "AccountViewController.h"

@implementation AccountNavigationController

- (id)init {
	if (self = [super init]) {
		AccountViewController* vc = [[AccountViewController alloc] init];
		self.title = vc.title;
		[self pushViewController:vc animated:NO];
	}
    return self;
}

@end
