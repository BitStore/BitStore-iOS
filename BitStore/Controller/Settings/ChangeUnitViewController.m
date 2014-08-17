//
//  ChangeUnitViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 20.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "ChangeUnitViewController.h"
#import "Unit.h"
#import "UserDefaults.h"
#import "Exchange.h"
#import "ExchangeHelper.h"
#import "ExchangeListener.h"
#import "Address.h"
#import "AddressHelper.h"
#import "Job.h"
#import "JobHelper.h"

@interface ChangeUnitViewController () <ExchangeListener>
@end

@implementation ChangeUnitViewController {
    NSArray* _units;
    Exchange* _exchange;
}

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.title = l10n(@"unit");
    _units = [Unit availableTypes];
    [[ExchangeHelper instance] addExchangeListener:self];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1.0];
    [self updateValues];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[PiwikTracker sharedInstance] sendViews:@"ChangeUnit", nil];
}

- (void)exchangeChanged:(Exchange *)exchange {
    _exchange = exchange;
    [self updateValues];
}

- (void)updateValues {
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _units.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
    [self configureCell:cell unit:[_units objectAtIndex:indexPath.row]];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell unit:(Unit *)unit {
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [unit displayName]];
    //cell.imageView.image = [UIImage imageNamed:currency];
    if ([_exchange.unit isEqual:unit]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Unit* unit = [_units objectAtIndex:indexPath.row];
    [[PiwikTracker sharedInstance] sendEventWithCategory:@"Events" action:[NSString stringWithFormat:@"ChangedUnit_%@", [unit displayName]] name:nil value:nil];
    [[ExchangeHelper instance] changeUnit:unit];
    NSString* url = [NSString stringWithFormat:@"%@?a=%@&u=%@", [API changeUnitUrl], [AddressHelper instance].defaultAddress.address, unit.technicalName];
    Job* job = [[Job alloc] initWithUrl:url];
    [[JobHelper instance] postJob:job];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
