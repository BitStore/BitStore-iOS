//
//  AccountViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "AccountViewController.h"
#import "Address.h"
#import "QRHelper.h"
#import "AddressListener.h"
#import "ExchangeHelper.h"
#import "ExchangeListener.h"
#import "TransactionCell.h"
#import "TransactionDetailViewController.h"
#import "Lockbox.h"
#import "SettingsViewController.h"
#import "AccountActionButton.h"
#import "SendNavigationController.h"
#import "ReceiveNavigationController.h"
#import "UserDefaults.h"
#import "AddressHelper.h"
#import "Unit.h"
#import "AddressHelperListener.h"
#import "BuyNavigationController.h"
#import "UIBAlertView.h"

@interface AccountViewController () <AddressListener, AddressHelperListener, ExchangeListener, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@end

@implementation AccountViewController {
	Address* _address;
	Exchange* _exchange;
	UILabel* _balanceBTCLabel;
	UILabel* _balanceCurLabel;
    UIRefreshControl* _refreshControl;
    UITableView* _tableView;
    UIView* _header;
    UIView* _divider;
    AccountActionButton* _sendButton;
    UIButton* _buyButton;
    BOOL _pulldownOpen;
    UIButton* _closeButton;
}

- (id)init {
	if (self = [super init]) {
		self.title = l10n(@"account");
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor whiteColor];
	_address = [AddressHelper instance].defaultAddress;
	[_address addAddressListener:self];
    [[AddressHelper instance] addAddressHelperListener:self];
    [self assembleViews];
	[self updateValues];
	[[ExchangeHelper instance] addExchangeListener:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   	[_address refresh];
    [[PiwikTracker sharedInstance] sendViews:@"Account", nil];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([Settings buyEnabled] && ![UserDefaults instance].buyShowed) {
        [self openPulldownWithAnimateButton:YES];
        [UserDefaults instance].buyShowed = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_refreshControl endRefreshing];
}

- (void)assembleViews {
    CGFloat headerHeight = 100;
    if ([Settings buyEnabled] && [UserDefaults instance].buyShowed && ![UserDefaults instance].buyDismissed) {
        headerHeight = 150;
    }
    
    _header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headerHeight)];
    _header.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.97];
    _header.clipsToBounds = YES;
    
	UIView* background = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, _header.frame.size.height)];
	[_header addSubview:background];
	
	UIView* foreground = [[UIView alloc] initWithFrame:CGRectMake(15, 30, self.view.frame.size.width - 30, _header.frame.size.height - 40)];
	[_header addSubview:foreground];
    
	_balanceBTCLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, foreground.frame.size.width, 30)];
	_balanceBTCLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:26];
	_balanceBTCLabel.textAlignment = NSTextAlignmentCenter;
	_balanceBTCLabel.textColor = [Color mainTintColor];
	[foreground addSubview:_balanceBTCLabel];
	
	_balanceCurLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, foreground.frame.size.width, 30)];
	_balanceCurLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
	_balanceCurLabel.textAlignment = NSTextAlignmentCenter;
	_balanceCurLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
	[foreground addSubview:_balanceCurLabel];
    
	
	NSString* receiveTitle = l10n(@"receive");
    AccountActionButton* receiveButton = [[AccountActionButton alloc] initWithTitle:receiveTitle image:[UIImage imageNamed:@"receive"] selectedImage:[UIImage imageNamed:@"receive_selected"]];
    receiveButton.padding = 10;
    CGSize receiveSize = [receiveTitle sizeWithAttributes:@{NSFontAttributeName:receiveButton.titleLabel.font}];
    receiveButton.frame = CGRectMake(0, 10, receiveSize.width, 50);
    [receiveButton addTarget:self action:@selector(actionReceive:) forControlEvents:UIControlEventTouchUpInside];
    [foreground addSubview:receiveButton];
    
    NSString* sendTitle = l10n(@"send");
    _sendButton = [[AccountActionButton alloc] initWithTitle:sendTitle image:[UIImage imageNamed:@"send"] selectedImage:[UIImage imageNamed:@"send_selected"]];
    _sendButton.padding = 5;
    CGSize sendSize = [sendTitle sizeWithAttributes:@{NSFontAttributeName:_sendButton.titleLabel.font}];
    _sendButton.frame = CGRectMake(foreground.frame.size.width - sendSize.width, 5, sendSize.width, 50);
    [_sendButton addTarget:self action:@selector(actionSend:) forControlEvents:UIControlEventTouchUpInside];
    [foreground addSubview:_sendButton];
    
    
    _divider = [[UIView alloc] initWithFrame:CGRectMake(0, _header.frame.size.height - 0.5, _header.frame.size.width, 0.5)];
    _divider.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    [_header addSubview:_divider];
	

    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 48)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
	_tableView.contentInset = UIEdgeInsetsMake(headerHeight, 0, 0, 0);
	_tableView.contentOffset = CGPointMake(0, -headerHeight);
    _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(headerHeight, 0, 0, 0);
    [self.view addSubview:_tableView];

//    UIView* wrapper = [[UIView alloc] initWithFrame:CGRectMake(0, headerHeight, 200, 30)];
//    UILabel* transactionsTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 190, 20)];
//    transactionsTitle.text = l10n(@"recent_transactions");
//    transactionsTitle.font = [UIFont systemFontOfSize:13];
//    transactionsTitle.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
//    [wrapper addSubview:transactionsTitle];
    
    [self.view addSubview:_header];
    _tableView.tableFooterView = [[UIView alloc] init];

    // this makes the top of the table view white
//	CGRect frame = _tableView.bounds;
//	frame.origin.y = -frame.size.height;
//	UIView* grayView = [[UIView alloc] initWithFrame:frame];
//	grayView.backgroundColor = [UIColor whiteColor];
//	[_tableView addSubview:grayView];
	
	
	_refreshControl = [[UIRefreshControl alloc]init];
    [_tableView addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
	
    
    if ([Settings buyEnabled]) {
        UIFont* buttonFont = [UIFont systemFontOfSize:14];
        NSString* buttonTitle = l10n(@"buy_btc");
        CGSize buttonSize = [buttonTitle sizeWithAttributes:@{NSFontAttributeName:buttonFont}];
        _buyButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - (buttonSize.width + 18) / 2, 105, buttonSize.width + 18, buttonSize.height + 18)];
        [_buyButton setTitle:buttonTitle forState:UIControlStateNormal];
        [_buyButton setTitleColor:[Color mainTintColor] forState:UIControlStateNormal];
        _buyButton.titleLabel.font = buttonFont;
        _buyButton.layer.cornerRadius = 4;
        _buyButton.layer.borderWidth = 1;
        _buyButton.layer.borderColor = [Color mainTintColor].CGColor;
        [_buyButton addTarget:self action:@selector(actionBuy:) forControlEvents:UIControlEventTouchUpInside];
        [_header addSubview:_buyButton];
        
        if (![UserDefaults instance].buyDismissed) {
            _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 101, 40, 40)];
            [_closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
            [_closeButton addTarget:self action:@selector(closePulldown) forControlEvents:UIControlEventTouchUpInside];
            [_header addSubview:_closeButton];
        }
        
        UIView* labelOverlay = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 90, 0, 180, 90)];
        labelOverlay.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchPulldown)];
        [labelOverlay addGestureRecognizer:tap];
        [_header addSubview:labelOverlay];
    }    
}

- (void)openPulldownWithAnimateButton:(BOOL)animateButton {
    _pulldownOpen = YES;
    [UIView animateWithDuration:0.3 animations:^() {
        CGFloat headerHeight = 150;
        _header.frame = CGRectMake(0, 0, self.view.frame.size.width, headerHeight);
        _divider.frame = CGRectMake(0, _header.frame.size.height - 0.5, _header.frame.size.width, 0.5);
        _tableView.contentInset = UIEdgeInsetsMake(headerHeight, 0, 0, 0);
        _tableView.contentOffset = CGPointMake(0, -headerHeight);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(headerHeight, 0, 0, 0);
    }];
    
    if (animateButton) {
        _buyButton.transform = CGAffineTransformMakeScale(0.7, 0.7);
        
        [UIView animateWithDuration:0.8 delay:0.2 usingSpringWithDamping:0.45 initialSpringVelocity:1.0 options:0
                         animations:^{
                             _buyButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

- (void)closePulldown {
    _pulldownOpen = NO;
    [UserDefaults instance].buyDismissed = YES;
    [UIView animateWithDuration:0.3 animations:^() {
        CGFloat headerHeight = 100;
        _header.frame = CGRectMake(0, 0, self.view.frame.size.width, headerHeight);
        _divider.frame = CGRectMake(0, _header.frame.size.height - 0.5, _header.frame.size.width, 0.5);
        _tableView.contentInset = UIEdgeInsetsMake(headerHeight, 0, 0, 0);
        _tableView.contentOffset = CGPointMake(0, -headerHeight);
        _tableView.scrollIndicatorInsets = UIEdgeInsetsMake(headerHeight, 0, 0, 0);
    } completion:^(BOOL finished) {
        [_closeButton removeFromSuperview];
    }];
}

- (void)switchPulldown {
    if (_pulldownOpen) {
        [self closePulldown];
    } else {
        [self openPulldownWithAnimateButton:NO];
    }
}

- (void)actionReceive:(id)sender {
    ReceiveNavigationController* vc = [[ReceiveNavigationController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)actionSend:(id)sender {
    SendNavigationController* vc = [[SendNavigationController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)actionBuy:(id)sender {
	if ([UserDefaults instance].buyEnabled) {
	    BuyNavigationController* vc = [[BuyNavigationController alloc] init];
		[self presentViewController:vc animated:YES completion:nil];
	} else {
		UIAlertView* av = [[UIAlertView alloc] initWithTitle:l10n(@"feature_unavailable") message:nil delegate:nil cancelButtonTitle:l10n(@"okay") otherButtonTitles:nil];
		[av show];
	}
}

- (void)refreshTable {
    [_address refresh];
}

#pragma mark - Listeners
- (void)addressChanged:(Address *)address {
	_address = address;
    [_refreshControl endRefreshing];
	[self updateValues];
}

- (void)defaultAddressChanged:(Address *)address {
    _address = address;
    [_address addAddressListener:self];
	[self updateValues];    
}

- (void)exchangeChanged:(Exchange *)exchange {
	_exchange = exchange;
	[self updateValues];
}

- (void)updateValues {
    _sendButton.enabled = _address.total > 10000;
    _balanceBTCLabel.text = [_exchange.unit valueForSatoshi:_address.total round:NO];
	_balanceCurLabel.text = [NSString stringWithFormat:@"%.2f %@", _exchange.current * (_address.total / 100000000.0f), _exchange.currency];
    [_tableView reloadData];
}

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _address.transactions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TransactionCell* cell = [tableView dequeueReusableCellWithIdentifier:@"transactionCell"];
    if (cell == nil) {
        cell = [[TransactionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"transactionCell"];
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
