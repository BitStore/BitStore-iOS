//
//  ShopsNavigationController.m
//  BitStore
//
//  Created by Dylan Marriott on 28/06/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "ShopsNavigationController.h"
#import "ShopsViewController.h"

@implementation ShopsNavigationController

- (id)init {
    if (self = [super init]) {
	    ShopsViewController* vc = [[ShopsViewController alloc] init];
		self.title = vc.title;
		[self pushViewController:vc animated:NO];
	}
    return self;
}

@end
