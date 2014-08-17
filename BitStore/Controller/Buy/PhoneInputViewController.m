//
//  PhoneInputViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 10.08.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "PhoneInputViewController.h"
#import "Order.h"
#import <Ringcaptcha/Ringcaptcha.h>
#import <Ringcaptcha/RingcaptchaAPI.h>
#import "PhoneVerificationViewController.h"
#import "UIBAlertView.h"

@interface PhoneInputViewController  () <RingcaptchaAPIDelegate>
@end

@implementation PhoneInputViewController {
    Order* _order;
    RingcaptchaCountry* _country;
    UITextField* _phoneInput;
    UIBarButtonItem* _nextItem;
    RingcaptchaAPI* _ringCaptcha;
}

- (id)initWithOrder:(Order *)order country:(NSString *)country {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _order = order;
        
        for (RingcaptchaCountry* c in [Ringcaptcha getSupportedCountries]) {
            if ([c.isoCode isEqualToString:country]) {
                _country = c;
            }
        }
        
        if (_country == nil) {
            UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:[NSString stringWithFormat:l10n(@"county_not_supported"), country] message:nil cancelButtonTitle:l10n(@"okay") otherButtonTitles:nil];
            [av showWithDismissHandler:^(NSInteger selectedIndex, NSString* selectedTitle, BOOL didCancel) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1.0];
    
    _nextItem = [[UIBarButtonItem alloc] initWithTitle:l10n(@"next") style:UIBarButtonItemStyleDone target:self action:@selector(next:)];
    _nextItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = _nextItem;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    _phoneInput = [[UITextField alloc] initWithFrame:CGRectMake(20, 45, cell.contentView.frame.size.width - 40, 44)];
    [_phoneInput addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
    _phoneInput.keyboardType = UIKeyboardTypePhonePad;
    _phoneInput.layer.cornerRadius = 4;
    _phoneInput.layer.borderColor = [UIColor colorWithWhite:0.74 alpha:1.0].CGColor;
    _phoneInput.layer.borderWidth = 1;
    _phoneInput.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, _phoneInput.frame.size.height)];
    container.backgroundColor = _phoneInput.backgroundColor;
    UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, container.frame.size.width - 10, container.frame.size.height)];
    UIImageView* flag = [[UIImageView alloc] initWithImage:_country.flag];
    flag.frame = CGRectMake(10, _phoneInput.frame.size.height / 2 - flag.frame.size.height / 2, flag.frame.size.width, flag.frame.size.height);
    [leftView addSubview:flag];
    UILabel* countryCode = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, leftView.frame.size.width - 10, leftView.frame.size.height - 2)];
    countryCode.textAlignment = NSTextAlignmentRight;
    countryCode.text = [NSString stringWithFormat:@"+%@", _country.dialingCode];
    countryCode.font = _phoneInput.font;
    countryCode.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    [leftView addSubview:countryCode];
    leftView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1.0];
    [container addSubview:leftView];
    _phoneInput.leftView = container;
    _phoneInput.leftViewMode = UITextFieldViewModeAlways;
    [cell.contentView addSubview:_phoneInput];
    
    [_phoneInput becomeFirstResponder];
    
    
    UILabel* instructions = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, cell.contentView.frame.size.width - 40, 30)];
    instructions.text = l10n(@"please_enter_phone");
    instructions.font = [UIFont systemFontOfSize:12];
    instructions.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    [cell.contentView addSubview:instructions];
    
    return cell;
}

- (void)editingChanged:(id)sender {
    _nextItem.enabled = _phoneInput.text.length > 0;
}

- (void)showHUD {
    MBProgressHUD* h = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [h becomeFirstResponder];
}

- (void)hideHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)next:(id)sender {
    [_phoneInput resignFirstResponder];
    
    if ([[Environment environment] isEqualToString:@"TEST"]) {
        [self showVerificationScreen];
    } else {
        [self showHUD];
        _ringCaptcha = [[RingcaptchaAPI alloc] initWithAppKey:[API ringCaptchaAppKey] andAPIKey:[API ringCaptchaAPIKey]];
        [_ringCaptcha sendCaptchaCodeToNumber:[self phoneNumber] withService:SMS delegate:self];
    }
}

- (void)didFinishCodeRequest:(RingcaptchaResponse *)rsp {
    [self hideHUD];
    [self showVerificationScreen];
}

- (void)didFinishCodeRequestWithError:(NSError *)err {
    [self hideHUD];
    UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:l10n(@"could_not_verify_phone") message:nil cancelButtonTitle:l10n(@"okay") otherButtonTitles: nil];
    [av showWithDismissHandler:^(NSInteger selectedIndex, NSString* selectedTitle, BOOL didCancel) {
        [_phoneInput becomeFirstResponder];
    }];
}

- (void)showVerificationScreen {
    _order.phoneNumber = [self phoneNumber];
    PhoneVerificationViewController* vc = [[PhoneVerificationViewController alloc] initWithOrder:_order ringCaptcha:_ringCaptcha];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)phoneNumber {
    return [NSString stringWithFormat:@"+%@%@", _country.dialingCode, _phoneInput.text];
}

@end
