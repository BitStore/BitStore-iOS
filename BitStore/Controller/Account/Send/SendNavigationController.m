//
//  SendNavigationController.m
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "SendNavigationController.h"
#import "SendViewController.h"

@implementation SendNavigationController

- (id)init {
    if (self = [super init]) {
	    SendViewController* vc = [[SendViewController alloc] init];
		self.title = vc.title;
		[self pushViewController:vc animated:NO];
	}
    return self;
}

- (id)initWithAddress:(NSString *)address amount:(NSString *)amount {
    if (self = [super init]) {
	    SendViewController* vc = [[SendViewController alloc] initWithAddress:address amount:amount];
		self.title = vc.title;
		[self pushViewController:vc animated:NO];
	}
    return self;
}

@end
