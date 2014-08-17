//
//  ContactDetailViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 18.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "ContactDetailViewController.h"
#import "AddressListener.h"
#import "Address.h"
#import "AddressHelper.h"
#import "AddressHelperListener.h"
#import "Transaction.h"
#import "Receiver.h"
#import "TransactionCell.h"
#import "TransactionDetailViewController.h"
#import "Exchange.h"
#import "ExchangeHelper.h"
#import "ExchangeListener.h"
#import "Unit.h"

@interface ContactDetailViewController () <AddressListener, AddressHelperListener, ExchangeListener, UITableViewDataSource, UITableViewDelegate>
@end

@implementation ContactDetailViewController {
    Address* _address;
    Exchange* _exchange;
    UILabel* _totalLabel;
    UIRefreshControl* _refreshControl;
    UITableView* _tableView;
}

- (id)initWithAddress:(Address *)address {
    if (self = [super init]) {
		_address = address;
		[_address addAddressListener:self];
		[[AddressHelper instance] addAddressHelperListener:self];
		[[ExchangeHelper instance] addExchangeListener:self];
		self.title = _address.label;
	}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _tableView.tableFooterView = [[UIView alloc] init];
    _tableView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.contentInset = UIEdgeInsetsMake(80, 0, 0, 0);
	_tableView.contentOffset = CGPointMake(0, -80);
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(80, 0, 0, 0);
    [self.view addSubview:_tableView];
    
    _refreshControl = [[UIRefreshControl alloc]init];
    [_tableView addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    
    UIView* header = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 80)];
    header.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.95];
    
    UIView* background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
	[header addSubview:background];
	
	UIView* foreground = [[UIView alloc] initWithFrame:CGRectMake(5, 5, self.view.frame.size.width - 10, 80 - 10)];
	[header addSubview:foreground];

    UITextView* addressLabel = [[UITextView alloc] initWithFrame:CGRectMake(4, 5, foreground.frame.size.width - 20, 35)];
    addressLabel.font = [UIFont systemFontOfSize:13];
    addressLabel.editable = NO;
    addressLabel.scrollEnabled = NO;
    addressLabel.text = _address.address;
    [foreground addSubview:addressLabel];
    
    _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35, foreground.frame.size.width - 20, 30)];
    _totalLabel.font = [UIFont systemFontOfSize:16];
    _totalLabel.textColor = [Color mainTintColor];
    [foreground addSubview:_totalLabel];
    
    
    UIView* divider = [[UIView alloc] initWithFrame:CGRectMake(0, 80, header.frame.size.width, 0.5)];
    divider.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    [header addSubview:divider];
    
    [self.view addSubview:header];
    
    [self updateValues];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_address refresh];
    [[PiwikTracker sharedInstance] sendViews:@"ContactsDetail", nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_refreshControl endRefreshing];
}

- (void)refreshTable {
    [_address refresh:YES];
}

- (void)addressChanged:(Address *)address {
    _address = address;
    [_refreshControl endRefreshing];
    [self updateValues];
}

- (void)defaultAddressChanged:(Address *)address {
    [self updateValues];
}

- (void)exchangeChanged:(Exchange *)exchange {
    _exchange = exchange;
    [self updateValues];
}

- (void)updateValues {
    _totalLabel.text = [NSString stringWithFormat:@"%@: %@", l10n(@"total"), [_exchange.unit valueForSatoshi:_address.total]];
    [_tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _address.transactions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TransactionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"transactionCell_c"];
    if (cell == nil) {
        cell = [[TransactionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"transactionCell_c"];
    }
    [cell setTransaction:[_address.transactions objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TransactionDetailViewController* vc = [[TransactionDetailViewController alloc] initWithTransaction:[_address.transactions objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

@end
