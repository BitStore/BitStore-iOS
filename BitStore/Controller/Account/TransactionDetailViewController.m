//
//  TransactionDetailViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "TransactionDetailViewController.h"
#import "Transaction.h"
#import "Address.h"
#import "Receiver.h"
#import "ContactHelper.h"
#import "BlockchainViewController.h"
#import "AddContactViewController.h"
#import "ContactListListener.h"
#import "Exchange.h"
#import "ExchangeHelper.h"
#import "ExchangeListener.h"
#import "Unit.h"

@interface TransactionDetailViewController () <ContactListListener, ExchangeListener>
@end

@implementation TransactionDetailViewController {
    Transaction* _transaction;
    NSString* _address;
    ContactList* _contactList;
    Exchange* _exchange;
}

- (id)initWithTransaction:(Transaction *)transaction {
    self = [super initWithStyle:UITableViewStyleGrouped];
    _transaction = transaction;
    self.title = l10n(@"transaction");
    
    if ([_transaction.orgAddress.address isEqualToString:_transaction.sender]) {
        Receiver* receiver = [_transaction.receiver objectAtIndex:0];
        _address = receiver.address;
    } else {
        _address = _transaction.sender;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[ContactHelper instance] addContactListListener:self];
    [[ExchangeHelper instance] addExchangeListener:self];
    [[PiwikTracker sharedInstance] sendViews:@"Transaction", nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([_contactList isContact:_address]) {
        return 2;
    } else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 1;
    } else {
        return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return l10n(@"transaction");
    } else if (section == 1) {
        return l10n(@"amount");
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
        
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateStyle:NSDateFormatterLongStyle];
            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
            UILabel* dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, cell.contentView.frame.size.width, 25)];
            dateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
            dateLabel.textColor = [UIColor darkGrayColor];
            dateLabel.text = [dateFormatter stringFromDate:_transaction.date];
            [cell.contentView addSubview:dateLabel];
            
            
            UILabel* confirmationsLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 44, cell.contentView.frame.size.width, 25)];
            confirmationsLabel.text = [NSString stringWithFormat:l10n(@"n_confirmation"), _transaction.confirmations];
            confirmationsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
            [cell.contentView addSubview:confirmationsLabel];
            
            if (_transaction.confirmations >= 6) {
                confirmationsLabel.textColor = [UIColor colorWithRed:0.09 green:0.39 blue:0.07 alpha:1.00];
            } else {
                confirmationsLabel.textColor = [UIColor colorWithRed:0.79 green:0.31 blue:0.10 alpha:1.00];
            }

            
            
            NSString* address;
            if ([_transaction.orgAddress.address isEqualToString:_transaction.sender]) {
                Receiver* receiver = [_transaction.receiver objectAtIndex:0];
                address = receiver.address;
            } else {
                address = _transaction.sender;
            }
            UITextView* addressLabel = [[UITextView alloc] initWithFrame:CGRectMake(10, 75, cell.contentView.frame.size.width, 25)];
            addressLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
            addressLabel.textColor = [UIColor grayColor];
            addressLabel.text = address;
            addressLabel.editable = NO;
            addressLabel.scrollEnabled = NO;
            [cell.contentView addSubview:addressLabel];
            
            cell.selectionStyle = UITableViewCellEditingStyleNone;
        }
    } else if (indexPath.section == 1) {
        UILabel* valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, cell.contentView.frame.size.width, 25)];
        valueLabel.text = [_exchange.unit valueForSatoshi:_transaction.total];
        valueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        valueLabel.textColor = [UIColor darkGrayColor];
        [cell.contentView addSubview:valueLabel];
        
        UILabel* currencyLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 38, cell.contentView.frame.size.width, 25)];
        currencyLabel.text = [NSString stringWithFormat:@"(%.2f %@)", fabs(_exchange.current * (_transaction.total / 100000000.0f)), _exchange.currency];
        currencyLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        currencyLabel.textColor = [UIColor grayColor];
        [cell.contentView addSubview:currencyLabel];
        
        cell.selectionStyle = UITableViewCellEditingStyleNone;
    } else if (indexPath.section == 2) {
        cell.textLabel.text = l10n(@"add_as_new_contact");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 110;
    } else if (indexPath.section == 1) {
        return 70;
    }
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2 && indexPath.row == 0) {
        [[PiwikTracker sharedInstance] sendEventWithCategory:@"Events" action:@"AddContactFromTX" label:@"AddContactFromTX"];
        AddContactViewController* vc = [[AddContactViewController alloc] initWithAddress:_address];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)contactListChanged:(ContactList *)contactList {
    _contactList = contactList;
    [self.tableView reloadData];
}

- (void)exchangeChanged:(Exchange *)exchange {
    _exchange = exchange;
    [self.tableView reloadData];
}

@end
