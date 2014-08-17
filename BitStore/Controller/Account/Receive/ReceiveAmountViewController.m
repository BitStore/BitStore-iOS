//
//  ReceiveAmountViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 26.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "ReceiveAmountViewController.h"
#import "AmountView.h"
#import "AmountViewDelegate.h"
#import "ReceiveAmountDelegate.h"

@interface ReceiveAmountViewController () <AmountViewDelegate>
@end

@implementation ReceiveAmountViewController {
    AmountView* _amountView;
    BTCSatoshi _satoshi;
    UIBarButtonItem* _saveItem;
    __weak id<ReceiveAmountDelegate> _delegate;
}

- (id)initWithDelegate:(id<ReceiveAmountDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

- (id)initWithDelegate:(id<ReceiveAmountDelegate>)delegate amount:(BTCSatoshi)amount {
    if (self = [self initWithDelegate:delegate]) {
        _satoshi = amount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = _saveItem;
    
    _amountView = [[AmountView alloc] initWithDelegate:self frame:CGRectMake(0, 20, self.view.frame.size.width, 60)];
    if (_satoshi > 0) {
        [_amountView setAmountValue:_satoshi];
    }
    [_amountView becomeFirstResponder];
    [self.view addSubview:_amountView];
}

- (void)amountValueChanged:(BTCSatoshi)satoshi {
    _satoshi = satoshi;
    //_saveItem.enabled = _satoshi > 0;
}

- (void)save:(id)sender {
    [_delegate amountSelected:_satoshi];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
