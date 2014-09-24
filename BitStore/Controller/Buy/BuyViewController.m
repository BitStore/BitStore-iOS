//
//  BuyViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 10.08.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "BuyViewController.h"
#import "UserDefaults.h"
#import "RequestHelper.h"
#import "AddressHelper.h"
#import "Address.h"
#import "UIBAlertView.h"
#import "CreditCardInputViewController.h"
#import "Order.h"

@implementation BuyViewController {
    NSString* _orderId;
    float _price;
    UISegmentedControl* _segmentedControl;
    UILabel* _amountLabel;
}

- (id)init {
    return [super initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1.0];

    [self createOrder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIBarButtonItem* cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
    
    UIBarButtonItem* rightItem;
    if ([UserDefaults instance].customerId == nil) {
        rightItem = [[UIBarButtonItem alloc] initWithTitle:l10n(@"next") style:UIBarButtonItemStyleDone target:self action:@selector(next:)];
    } else {
        rightItem = [[UIBarButtonItem alloc] initWithTitle:l10n(@"buy") style:UIBarButtonItemStyleDone target:self action:@selector(buy:)];
    }
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)next:(id)sender {
//    CreditCardInputViewController* vc = [[CreditCardInputViewController alloc] initWithOrder:[[Order alloc] initWithOrderId:_orderId amount:[self amount] price:_price]];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showHUD {
    MBProgressHUD* h = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [h becomeFirstResponder];
}

- (void)hideHUD {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)createOrder {
    [self showHUD];
    RequestHelper* rh = [[RequestHelper alloc] init];
    NSString* url = [NSString stringWithFormat:@"%@?address=%@", [API createOrderUrl], [AddressHelper instance].defaultAddress.address];
    if ([UserDefaults instance].customerId) {
        url = [NSString stringWithFormat:@"%@&customerId=%@", url, [UserDefaults instance].customerId];
    }
	
	[rh startRequestWithUrl:url completion:^(BOOL success, NSData* data) {
		[self hideHUD];
		if (success) {
			NSError* error;
			NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
			if (error == nil) {
				_orderId = [json objectForKey:@"orderId"];
				_price = ((NSString *)[json objectForKey:@"price"]).floatValue;
				[self.tableView reloadData];
			} else {
				[self showCreateOrderError];
			}
		} else {
			[self showCreateOrderError];
		}
	}];
}

- (void)showCreateOrderError {
    UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:l10n(@"network_error") message:nil cancelButtonTitle:l10n(@"cancel") otherButtonTitles:l10n(@"retry"), nil];
    [av showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL didCancel) {
        if (didCancel) {
            [self dismissViewControllerAnimated:NO completion:nil];
        } else {
            [self createOrder];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 105;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _orderId == nil ? 0 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"$10", @"$20", @"$50", nil]];
    _segmentedControl.frame = CGRectMake(self.view.frame.size.width / 2 - 145, 20, 290, 44);
    _segmentedControl.tintColor = [Color mainTintColor];
    _segmentedControl.selectedSegmentIndex = 1;
    [_segmentedControl addTarget:self action:@selector(selectionChanged:) forControlEvents:UIControlEventValueChanged];
    [cell.contentView addSubview:_segmentedControl];
    
    
    _amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 64, self.view.frame.size.width, 30)];
    _amountLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    _amountLabel.font = [UIFont systemFontOfSize:13];
    [cell.contentView addSubview:_amountLabel];
    
    
    [self selectionChanged:_segmentedControl];
    
    return cell;
}

- (void)selectionChanged:(id)sender {
    _amountLabel.text = [NSString stringWithFormat:l10n(@"you_will_receive"), [self amount] / _price];
}

- (int)amount {
    int amount;
    switch (_segmentedControl.selectedSegmentIndex) {
        case 0:
            amount = 10;
            break;
        case 1:
            amount = 20;
            break;
        case 2:
            amount = 50;
            break;
        default:
            amount = 0;
            break;
    }
    return amount;
}

- (void)buy:(id)sender {
    UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:l10n(@"confirm_buy"), ([self amount] / _price), [self amount]] cancelButtonTitle:l10n(@"cancel") otherButtonTitles:l10n(@"buy"), nil];
    [av showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL didCancel) {
        if (!didCancel) {
            [self doOrder:_orderId];;
        }
    }];
}

- (void)doOrder:(NSString *)orderId {
    [self showHUD];
    RequestHelper* rh = [[RequestHelper alloc] init];
    NSString* url = [NSString stringWithFormat:@"%@?orderId=%@&amount=%i&customerId=%@", [API doOrderUrl], orderId, [self amount], [UserDefaults instance].customerId];
    
	[rh startRequestWithUrl:url completion:^(BOOL success, NSData* data) {
		if (success) {
			NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			if ([result isEqualToString:@"success"]) {
				UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:l10n(@"success") message:l10n(@"btc_bought_successfully") cancelButtonTitle:nil otherButtonTitles:l10n(@"okay"), nil];
				[av showWithDismissHandler:^(NSInteger selectedIndex, NSString* selectedTitle, BOOL didCancel) {
					[[AddressHelper instance].defaultAddress refresh];
					[self dismissViewControllerAnimated:YES completion:nil];
				}];
			} else if ([result isEqualToString:@"no_credit"]) {
				UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:l10n(@"error") message:l10n(@"no_credit") cancelButtonTitle:l10n(@"okay") otherButtonTitles: nil];
				[av showWithDismissHandler:^(NSInteger selectedIndex, NSString* selectedTitle, BOOL didCancel) {
					[self dismissViewControllerAnimated:NO completion:nil];
				}];
			} else {
				[self showDoOrderError:orderId];
			}
		} else {
			[self showDoOrderError:orderId];
		}
	}];
}

- (void)showDoOrderError:(NSString *)orderId {
    UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:l10n(@"network_error") message:nil cancelButtonTitle:l10n(@"cancel") otherButtonTitles:l10n(@"retry"), nil];
    [av showWithDismissHandler:^(NSInteger selectedIndex, NSString* selectedTitle, BOOL didCancel) {
        if (didCancel) {
            [self dismissViewControllerAnimated:NO completion:nil];
        } else {
            [self doOrder:orderId];
        }
    }];
}

@end
