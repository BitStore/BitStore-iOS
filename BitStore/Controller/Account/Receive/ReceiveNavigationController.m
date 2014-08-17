//
//  ReceiveNavigationController.m
//  BitStore
//
//  Created by Dylan Marriott on 10.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "ReceiveNavigationController.h"
#import "ReceiveViewController.h"

@implementation ReceiveNavigationController

- (id)init {
    if (self = [super init]) {
	    ReceiveViewController* vc = [[ReceiveViewController alloc] init];
		self.title = vc.title;
		[self pushViewController:vc animated:NO];
	}
    return self;
}


@end
