//
//  ScanNavigationController.m
//  BitStore
//
//  Created by Dylan Marriott on 20.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "ScanNavigationController.h"
#import "ScanViewController.h"

@implementation ScanNavigationController {
    ScanViewController* _vc;
}

- (id)initWithScanDelegate:(id<ScanDelegate>)delegate {
    if (self = [super init]) {
		_vc = [[ScanViewController alloc] init];
		self.title = _vc.title;
		_vc.delegate = delegate;
		[self pushViewController:_vc animated:NO];
	}
    return self;
}

- (void)reset {
    [_vc reset];
}

@end
