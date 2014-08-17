//
//  ShopsViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 28/06/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "ShopsViewController.h"

@implementation ShopsViewController

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.title = l10n(@"shops");
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[PiwikTracker sharedInstance] sendViews:@"Shops", nil];
}

@end
