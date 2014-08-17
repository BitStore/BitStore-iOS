//
//  TransactionCell.m
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "TransactionCell.h"
#import "ExchangeHelper.h"
#import "ExchangeListener.h"
#import "Transaction.h"
#import "Address.h"
#import "Receiver.h"
#import "ContactHelper.h"
#import "ContactListListener.h"
#import "Unit.h"

@interface TransactionCell () <ExchangeListener, ContactListListener>
@end

@implementation TransactionCell {
    Exchange* _exchange;
    ContactList* _contactList;
    Transaction* _transaction;
    UILabel* _personLabel;
    UILabel* _valueLabel;
    UILabel* _dateLabel;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    _personLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 170, 55)];
    _personLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    [self addSubview:_personLabel];
    
    _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 210, 8, 200, 20)];
    _valueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    _valueLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_valueLabel];
    
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 210, 28, 200, 20)];
    _dateLabel.font = [UIFont systemFontOfSize:11];
    _dateLabel.textAlignment = NSTextAlignmentRight;
    _dateLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
    [self addSubview:_dateLabel];
    
    [[ExchangeHelper instance] addExchangeListener:self];
    [[ContactHelper instance] addContactListListener:self];

    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    
    return self;
}

- (void)setTransaction:(Transaction *)transaction {
    _transaction = transaction;
    [self updateValues];
}   

- (void)exchangeChanged:(Exchange *)exchange {
    _exchange = exchange;
    [self updateValues];
}

- (void)contactListChanged:(ContactList *)contactList {
    _contactList = contactList;
    [self updateValues];
}

- (void)updateValues {
    NSString* address;
    if ([_transaction.orgAddress.address isEqualToString:_transaction.sender]) {
        Receiver* receiver = [_transaction.receiver objectAtIndex:0];
        address = receiver.address;
        _valueLabel.textColor = [UIColor colorWithRed:0.58 green:0.12 blue:0.18 alpha:1.00];
    } else {
        address = _transaction.sender;
        _valueLabel.textColor = [UIColor colorWithRed:0.24 green:0.48 blue:0.14 alpha:1.00];
    }
    
    _personLabel.text = [_contactList displayTextForAddress:address];
    _valueLabel.text = [_exchange.unit valueForSatoshi:_transaction.total];
    if (_transaction.confirmations < 6) {
        _dateLabel.text = @"Pending";
    } else {
        _dateLabel.text = _transaction.date.dateTimeAgo;
    }
}

@end
