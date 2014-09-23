//
//  AddContactViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "AddContactViewController.h"
#import "ScanNavigationController.h"
#import "ScanDelegate.h"
#import "ContactHelper.h"
#import "Address.h"

@interface AddContactViewController () <UITextFieldDelegate, ScanDelegate>
@end

@implementation AddContactViewController {
    UITextField* _nameField;
    UITextField* _addressField;
    ScanNavigationController* _scanViewController;
    NSString* _address;
}

- (id)initWithAddress:(NSString *)address {
    if (self = [super init]) {
		_address = address;
	}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = l10n(@"new_contact");
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    
    UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    saveItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = saveItem;
    
    UIBarButtonItem* cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    _nameField = [[UITextField alloc] initWithFrame:CGRectMake(20, 20, self.view.frame.size.width - 40, 30)];
    [_nameField becomeFirstResponder];
    _nameField.placeholder = l10n(@"display_name");
    _nameField.delegate = self;
    _nameField.borderStyle = UITextBorderStyleRoundedRect;
    _nameField.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:_nameField];
    
    CGFloat rightMargin = 80;
    if (_address) {
        rightMargin = 40;
    }
    _addressField = [[UITextField alloc] initWithFrame:CGRectMake(20, 60, self.view.frame.size.width - rightMargin, 30)];
    _addressField.placeholder = l10n(@"btc_address");
    _addressField.delegate = self;
    _addressField.borderStyle = UITextBorderStyleRoundedRect;
    _addressField.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:_addressField];
    
    if (_address) {
        _addressField.text = _address;
        _addressField.enabled = NO;
    }
    
    if (!_address) {
        UIButton* scanButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 44, 58, 32, 32)];
        [scanButton setImage:[UIImage imageNamed:@"scan"] forState:UIControlStateNormal];
        [scanButton addTarget:self action:@selector(scan:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:scanButton];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[PiwikTracker sharedInstance] sendViews:@"ContactsAdd", nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    [textField setText:[textField.text stringByReplacingCharactersInRange:range withString:string]];

    BOOL exists = NO;
    for (Address* contact in [ContactHelper instance].contacts) {
        if ([contact.label.lowercaseString isEqualToString:_nameField.text.lowercaseString]) {
            exists = YES;
            break;
        }
    }
    if (exists) {
        _nameField.textColor = [UIColor redColor];
    } else {
        _nameField.textColor = [UIColor blackColor];
    }

    BTCAddress* addr = [BTCAddress addressWithBase58String:_addressField.text];
    if (addr != nil && [addr isPublicAddress] && _nameField.text.length > 0 && !exists) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _nameField) {
        [_addressField becomeFirstResponder];
    } else if (textField == _addressField) {
        [_nameField becomeFirstResponder];
    }
    return NO;
}

- (void)scan:(id)sender {
    _scanViewController = [[ScanNavigationController alloc] initWithScanDelegate:self];
    [self presentViewController:_scanViewController animated:YES completion:nil];
}

- (void)save:(id)sender {
    [[ContactHelper instance] addContact:_nameField.text address:_addressField.text];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scannedAddress:(NSString *)address amount:(NSString *)amount {
    [_scanViewController dismissViewControllerAnimated:YES completion:nil];
    [self setAddressText:address];
}

- (void)setAddressText:(NSString *)address {
    _addressField.text = @"";
    NSRange range = {0, 0};
    [self textField:_addressField shouldChangeCharactersInRange:range replacementString:address];
}

@end
