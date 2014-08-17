//
//  CreditCardInputViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 26.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "CreditCardInputViewController.h"
#import "STPView.h"
#import "RequestHelper.h"
#import "AddressHelper.h"
#import "Address.h"
#import "UIBAlertView.h"
#import "Order.h"
#import "PhoneInputViewController.h"

@interface CreditCardInputViewController () <STPViewDelegate>
@end

@implementation CreditCardInputViewController {
    STPView* _stripeView;
    UITextField* _zipField;
    UIBarButtonItem* _nextItem;
    BOOL _stripeValid;
    Order* _order;
}

- (id)initWithOrder:(Order *)order {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        _order = order;
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


//    NSString* key = @"stripe key";
//    if ([[Environment environment] isEqualToString:@"TEST"]) {
//         key = @"stripe test key";
//    }
    NSString* key = nil;
    NSAssert(key, @"Buy feature is deactivated");
    
    _stripeView = [[STPView alloc] initWithFrame:CGRectMake(15, 20, 290, 55) andKey:key];
    _stripeView.delegate = self;
    [cell.contentView addSubview:_stripeView];
    
    _zipField = [[UITextField alloc] initWithFrame:CGRectMake(15, 85, 290, 44)];
    [_zipField addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
    _zipField.placeholder = l10n(@"zip_placeholder");
    _zipField.layer.cornerRadius = 4;
    _zipField.layer.borderColor = [UIColor colorWithRed:0.74 green:0.74 blue:0.74 alpha:1.00].CGColor;
    _zipField.layer.borderWidth = 1;
    _zipField.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1.00];
    UIView* leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, _zipField.frame.size.height)];
    leftView.backgroundColor = _zipField.backgroundColor;
    _zipField.leftView = leftView;
    _zipField.leftViewMode = UITextFieldViewModeAlways;
    _zipField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [cell.contentView addSubview:_zipField];
    
    return cell;
}

- (void)stripeView:(STPView *)view withCard:(PKCard *)card isValid:(BOOL)valid {
    _stripeValid = valid;
    [self validate];
}

- (void)editingChanged:(id)sender {
    [self validate];
}

- (void)validate {
    _nextItem.enabled = _stripeValid && _zipField.text.length > 0;
}

- (void)next:(id)sender {
    [_stripeView.paymentView resignFirstResponder];
    [_zipField resignFirstResponder];
    
    [self showHUD];
    
    PKCard* pkCard = _stripeView.paymentView.card;
    STPCard* card = [[STPCard alloc] init];
    card.number = pkCard.number;
    card.expMonth = pkCard.expMonth;
    card.expYear = pkCard.expYear;
    card.cvc = pkCard.cvc;
    card.addressZip = _zipField.text;
    
    [Stripe createTokenWithCard:card publishableKey:_stripeView.key completion:^(STPToken* token, NSError* error) {
        [self hideHUD];
        if (error) {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:l10n(@"error")
                                                              message:[error localizedDescription]
                                                             delegate:nil
                                                    cancelButtonTitle:l10n(@"okay")
                                                    otherButtonTitles:nil];
            [message show];
        } else {
            _order.token = token.tokenId;
            _order.fingerprint = token.card.fingerprint;
            PhoneInputViewController* vc = [[PhoneInputViewController alloc] initWithOrder:_order country:token.card.country];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (void)showHUD {
    MBProgressHUD* h = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [h becomeFirstResponder];
}

- (void)hideHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

@end
