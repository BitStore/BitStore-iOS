//
//  ChangeCurrencyViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "ChangeCurrencyViewController.h"
#import "ExchangeHelper.h"
#import "ExchangeListener.h"
#import "DebugViewController.h"

@interface ChangeCurrencyViewController () <ExchangeListener>
@end

@implementation ChangeCurrencyViewController {
    Exchange* _exchange;
    NSArray* _currencies;
}

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.title = l10n(@"change_currency");
    _currencies = [NSArray arrayWithObjects:@"USD", @"EUR", @"CHF", @"AUD", @"BRL", @"CAD", @"CNY", @"DKK", @"GBP", @"HKD", @"MXN", @"NOK", @"RUB", @"SGD", nil];
    [[ExchangeHelper instance] addExchangeListener:self];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1.0];
    [self updateValues];
    
    UILongPressGestureRecognizer* tap = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
#ifdef DEBUG
        tap.numberOfTouchesRequired = 2;
#else
        tap.numberOfTouchesRequired = 3;
#endif
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[PiwikTracker sharedInstance] sendViews:@"ChangeCurrency", nil];
}

- (void)exchangeChanged:(Exchange *)exchange {
    _exchange = exchange;
    [self updateValues];
}

- (void)updateValues {
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _currencies.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
    [self configureCell:cell currency:[_currencies objectAtIndex:indexPath.row]];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell currency:(NSString *)currency {
    cell.textLabel.text = [NSString stringWithFormat:@"%@", currency];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"1 BTC = %.2f %@", [_exchange valueForCurrency:currency], currency];
    cell.imageView.image = [UIImage imageNamed:currency];
    if ([_exchange.currency isEqualToString:currency]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[PiwikTracker sharedInstance] sendEventWithCategory:@"Events" action:@"ChangedCurrency" name:nil value:nil];
    [[ExchangeHelper instance] changeCurreny:[_currencies objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tap:(UITapGestureRecognizer *)recognizer {
    DebugViewController* vc = [[DebugViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
