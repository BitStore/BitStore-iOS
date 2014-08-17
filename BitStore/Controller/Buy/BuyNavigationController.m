//
//  BuyNavigationController.m
//  BitStore
//
//  Created by Dylan Marriott on 26.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "BuyNavigationController.h"
#import "BuyViewController.h"

@implementation BuyNavigationController

- (id)init {
    if (self = [super init]) {
		BuyViewController* vc = [[BuyViewController alloc] init];
		self.title = vc.title;
		[self pushViewController:vc animated:NO];
	}
    return self;
}


@end
