//
//  PhoneVerificationViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 10.08.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "PhoneVerificationViewController.h"
#import "Order.h"
#import <Ringcaptcha/Ringcaptcha.h>
#import <Ringcaptcha/RingcaptchaAPI.h>
#import "RequestHelper.h"
#import "UIBAlertView.h"
#import "UserDefaults.h"

@interface PhoneVerificationViewController  () <RingcaptchaAPIDelegate, UITextFieldDelegate>
@end

@implementation PhoneVerificationViewController {
    Order* _order;
    RingcaptchaAPI* _ringCaptcha;
    UIBarButtonItem* _nextItem;
    UITextField* _digit1;
    UITextField* _digit2;
    UITextField* _digit3;
    UITextField* _digit4;
    UIActivityIndicatorView* _indicator;
}

- (id)initWithOrder:(Order *)order ringCaptcha:(RingcaptchaAPI *)ringCaptcha {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _order = order;
        _ringCaptcha = ringCaptcha;
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
    return 150;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat x_padding = 30;
    CGFloat y_padding = 50;
    CGFloat itemWidth = 44;
    int space = (int)((cell.contentView.frame.size.width - (itemWidth * 4) - (x_padding * 2)) / 3);
    
    _digit1 = [[UITextField alloc] initWithFrame:CGRectMake(x_padding, y_padding, itemWidth, itemWidth)];
    [self applyStyles:_digit1];
    [cell.contentView addSubview:_digit1];
    
    _digit2 = [[UITextField alloc] initWithFrame:CGRectMake(x_padding + ((itemWidth + space) * 1), y_padding, itemWidth, itemWidth)];
    [self applyStyles:_digit2];
    [cell.contentView addSubview:_digit2];
    
    _digit3 = [[UITextField alloc] initWithFrame:CGRectMake(x_padding + ((itemWidth + space) * 2), y_padding, itemWidth, itemWidth)];
    [self applyStyles:_digit3];
    [cell.contentView addSubview:_digit3];
    
    _digit4 = [[UITextField alloc] initWithFrame:CGRectMake(x_padding + ((itemWidth + space) * 3), y_padding, itemWidth, itemWidth)];
    [self applyStyles:_digit4];
    [cell.contentView addSubview:_digit4];
    
    [_digit1 becomeFirstResponder];
    
    
    UILabel* instructions = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, cell.contentView.frame.size.width - 60, 30)];
    instructions.text = l10n(@"please_enter_verification");
    instructions.font = [UIFont systemFontOfSize:12];
    instructions.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    [cell.contentView addSubview:instructions];
    
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicator.frame = CGRectMake(cell.contentView.frame.size.width / 2 - 16, 106, 32, 32);
    _indicator.hidden = YES;
    [cell.contentView addSubview:_indicator];
    
    return cell;
}

- (void)applyStyles:(UITextField *)textField {
    textField.keyboardType = UIKeyboardTypePhonePad;
    textField.layer.cornerRadius = 4;
    textField.layer.borderColor = [UIColor colorWithWhite:0.74 alpha:1.0].CGColor;
    textField.layer.borderWidth = 1;
    textField.backgroundColor = [UIColor colorWithWhite:0.96 alpha:1.0];
    textField.textAlignment = NSTextAlignmentCenter;
    textField.delegate = self;
    [textField addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    return newLength <= 1 || returnKey;
}

- (void)editingChanged:(UITextField *)sender {
    if (sender.text.length > 0) {
        if (sender == _digit1) {
            [_digit2 becomeFirstResponder];
        } else if (sender == _digit2) {
            [_digit3 becomeFirstResponder];
        } else if (sender == _digit3) {
            [_digit4 becomeFirstResponder];
        }
    } else {
        if (sender == _digit4) {
            [_digit3 becomeFirstResponder];
        } else if (sender == _digit3) {
            [_digit2 becomeFirstResponder];
        } else if (sender == _digit2) {
            [_digit1 becomeFirstResponder];
        }
    }
    
    NSString* code = [NSString stringWithFormat:@"%@%@%@%@", _digit1.text, _digit2.text, _digit3.text, _digit4.text];
    if (code.length == 4) {
        
        if ([[Environment environment] isEqualToString:@"TEST"]) {
            _nextItem.enabled = YES;
        } else {
            _indicator.hidden = NO;
            [_indicator startAnimating];
            [self setFieldsEnabled:NO];
            [_ringCaptcha verifyCaptchaWithCode:code delegate:self];
        }
    }
}

- (void)didFinishVerifyRequest:(RingcaptchaResponse *)rsp {
    [_indicator stopAnimating];
    _indicator.hidden = YES;
    [self setFieldsEnabled:YES];
    if ([rsp.status isEqualToString:@"SUCCESS"]) {
        _nextItem.enabled = YES;
        [self markFieldsAsSuccess];
    } else {
        _nextItem.enabled = NO;
        [self markFieldsAsError];
    }
}

- (void)didFinishVerifyRequestWithError:(NSError *)err {
    [_indicator stopAnimating];
    _indicator.hidden = YES;
    [self setFieldsEnabled:YES];
    _nextItem.enabled = NO;
    [self markFieldsAsError];
}

- (void)markFieldsAsError {
    _digit1.layer.borderColor = [UIColor redColor].CGColor;
    _digit2.layer.borderColor = [UIColor redColor].CGColor;
    _digit3.layer.borderColor = [UIColor redColor].CGColor;
    _digit4.layer.borderColor = [UIColor redColor].CGColor;
}

- (void)markFieldsAsSuccess {
    _digit1.layer.borderColor = [UIColor colorWithRed:0.06 green:0.42 blue:0.07 alpha:1.00].CGColor;
    _digit2.layer.borderColor = [UIColor colorWithRed:0.06 green:0.42 blue:0.07 alpha:1.00].CGColor;
    _digit3.layer.borderColor = [UIColor colorWithRed:0.06 green:0.42 blue:0.07 alpha:1.00].CGColor;
    _digit4.layer.borderColor = [UIColor colorWithRed:0.06 green:0.42 blue:0.07 alpha:1.00].CGColor;
}

- (void)setFieldsEnabled:(BOOL)enabled {
    _digit1.enabled = enabled;
    _digit2.enabled = enabled;
    _digit3.enabled = enabled;
    _digit4.enabled = enabled;
    
    if (enabled) {
        [_digit4 becomeFirstResponder];
    }
}

- (void)showHUD {
    MBProgressHUD* h = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [h becomeFirstResponder];
}

- (void)hideHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)next:(id)sender {
    [_digit1 resignFirstResponder];
    [_digit2 resignFirstResponder];
    [_digit3 resignFirstResponder];
    [_digit4 resignFirstResponder];
    
    [self showHUD];
    RequestHelper* rh = [[RequestHelper alloc] init];
    NSString* url = [NSString stringWithFormat:@"%@?token=%@&fingerprint=%@&phonenr=%@", [API createCustomerUrl], _order.token, _order.fingerprint, _order.phoneNumber];
	
	[rh startRequestWithUrl:url completion:^(BOOL success, NSData* data) {
		[self hideHUD];
		if (success) {
			NSError* error;
			NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
			if (!error) {
				if ([json objectForKey:@"error"] == [NSNull null]) {
					NSString* customerId = [json objectForKey:@"customerId"];
					[UserDefaults instance].customerId = customerId;
					[self.navigationController popToRootViewControllerAnimated:YES];
				} else {
					NSString* error = [json objectForKey:@"error"];
					if ([error isEqualToString:@"card_error"]) {
						[self showOtherError:l10n(@"buy_card_error")];
					} else if ([error isEqualToString:@"phone_nr_already_used"]) {
						[self showOtherError:l10n(@"buy_phone_nr_already_used")];
					} else if ([error isEqualToString:@"card_check_failed"]) {
						[self showOtherError:l10n(@"buy_card_check_failed")];
					} else {
						[self showNetworkError];
					}
				}
			} else {
				[self showNetworkError];
			}
		} else {
			[self showNetworkError];
		}
	}];
}

- (void)showNetworkError {
    UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:l10n(@"network_error") message:nil cancelButtonTitle:l10n(@"cancel") otherButtonTitles:l10n(@"retry"), nil];
    [av showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL didCancel) {
        if (didCancel) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [self next:nil];
        }
    }];
}

- (void)showOtherError:(NSString *)msg {
    UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:l10n(@"error") message:msg cancelButtonTitle:l10n(@"okay") otherButtonTitles: nil];
    [av showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL didCancel) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

@end
