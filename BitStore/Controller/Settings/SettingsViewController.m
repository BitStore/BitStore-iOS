//
//  SettingsViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 28/06/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "SettingsViewController.h"
#import "Exchange.h"
#import "ExchangeHelper.h"
#import "ExchangeListener.h"
#import "ChangeCurrencyViewController.h"
#import "KeysViewController.h"
#import "SwipeViewController.h"
#import "LTHPasscodeViewController.h"
#import "UserDefaults.h"
#import "PushHelper.h"
#import "Unit.h"
#import "ChangeUnitViewController.h"

@interface SettingsViewController () <ExchangeListener, LTHPasscodeViewControllerDelegate>
@end

@implementation SettingsViewController {
    Exchange* _exchange;
    UISwitch* _pushToggle;
    UISwitch* _passcodeToggle;
}

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.title = l10n(@"settings");
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
    [[PiwikTracker sharedInstance] sendViews:@"Settings", nil];
}

- (void)exchangeChanged:(Exchange *)exchange {
    _exchange = exchange;
    [self updateValues];
}

- (void)updateValues {
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else if (section == 1) {
        return 2;
    }
    NSAssert(NO, @"");
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@""];
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", _exchange.currency];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"1 BTC = %.2f %@", _exchange.current, _exchange.currency];
        cell.imageView.image = [UIImage imageNamed:_exchange.currency];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", l10n(@"unit"), [_exchange.unit displayName]];
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"1 BTC = %.2f %@", _exchange.current, _exchange.currency];
        cell.imageView.image = [UIImage imageNamed:@"coin"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 0 && indexPath.row == 2) {
        cell.textLabel.text = l10n(@"push_notifications_title");
        cell.detailTextLabel.text = l10n(@"push_notifications_desc");
        cell.imageView.image = [UIImage imageNamed:@"push"];
        _pushToggle = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 66, 10, 0, 0)];
        [_pushToggle addTarget:self action:@selector(pushToggle) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:_pushToggle];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [_pushToggle setOn:[UserDefaults instance].pushActive];
    } else if (indexPath.section == 0 && indexPath.row == 3) {
        cell.textLabel.text = l10n(@"passcode");
        cell.imageView.image = [UIImage imageNamed:@"lock"];
        _passcodeToggle = [[UISwitch alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 66, 10, 0, 0)];
        [_passcodeToggle addTarget:self action:@selector(passcodeToggle) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:_passcodeToggle];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([LTHPasscodeViewController doesPasscodeExist]) {
            [_passcodeToggle setOn:YES];
        }
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        cell.textLabel.text = l10n(@"private_keys");
        cell.imageView.image = [UIImage imageNamed:@"key"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        cell.textLabel.text = l10n(@"swipe");
        cell.imageView.image = [UIImage imageNamed:@"camera"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 0) {
        ChangeCurrencyViewController* vc = [[ChangeCurrencyViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        ChangeUnitViewController* vc = [[ChangeUnitViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        KeysViewController* vc = [[KeysViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.section == 1 && indexPath.row == 1) {
        SwipeViewController* vc = [[SwipeViewController alloc] init];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)passcodeToggle {
    [LTHPasscodeViewController sharedUser].delegate = self;
	[LTHPasscodeViewController sharedUser].maxNumberOfAllowedFailedAttempts = 3;
    if (_passcodeToggle.isOn) {
        [[LTHPasscodeViewController sharedUser] showForEnablingPasscodeInViewController:self asModal:YES];
    } else {
        [[LTHPasscodeViewController sharedUser] showForDisablingPasscodeInViewController:self asModal:YES];
    }
}

- (void)pushToggle {
    [UserDefaults instance].pushActive = _pushToggle.isOn;
    if (_pushToggle.isOn) {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    } else {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        [PushHelper unregister];
    }
}


- (void)passcodeViewControllerWillClose {
    if ([LTHPasscodeViewController doesPasscodeExist]) {
        [_passcodeToggle setOn:YES];
    } else {
        [_passcodeToggle setOn:NO];
    }
}

- (void)maxNumberOfFailedAttemptsReached {
    [[LTHPasscodeViewController sharedUser] dismissViewControllerAnimated:YES completion:^() {
        [[LTHPasscodeViewController sharedUser] reset];
    }];
    if ([LTHPasscodeViewController doesPasscodeExist]) {
        [_passcodeToggle setOn:YES];
    } else {
        [_passcodeToggle setOn:NO];
    }
}

@end
