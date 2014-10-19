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
#import "CircleIndicator.h"

@interface TransactionCell () <ExchangeListener, ContactListListener>
@end

@implementation TransactionCell {
    Exchange* _exchange;
    ContactList* _contactList;
    Transaction* _transaction;
    UILabel* _personLabel;
    UILabel* _valueLabel;
    UILabel* _dateLabel;
    CircleIndicator* _circleIndicator;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    _personLabel = [[UILabel alloc] init];
    _personLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    [self addSubview:_personLabel];
    
    _valueLabel = [[UILabel alloc] init];
    _valueLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    _valueLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_valueLabel];
    
    _dateLabel = [[UILabel alloc] init];
    _dateLabel.font = [UIFont systemFontOfSize:11];
    _dateLabel.textAlignment = NSTextAlignmentRight;
    _dateLabel.textColor = [UIColor colorWithWhite:0.65 alpha:1.0];
    _dateLabel.hidden = YES;
    [self addSubview:_dateLabel];
    
    _circleIndicator = [[CircleIndicator alloc] initWithCircles:6];
    _circleIndicator.frame = CGRectMake(self.frame.size.width - 80, 30, 70, 20);
    _circleIndicator.hidden = YES;
    [self addSubview:_circleIndicator];
    
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
        _circleIndicator.hidden = NO;
        _dateLabel.hidden = YES;
        [_circleIndicator setFilledCircles:_transaction.confirmations];
    } else {
        _circleIndicator.hidden = YES;
        _dateLabel.hidden = NO;
        _dateLabel.text = _transaction.date.dateTimeAgo;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _personLabel.frame = CGRectMake(10, 0, self.frame.size.width - 145, 55);
    _valueLabel.frame = CGRectMake(self.frame.size.width - 135, 8, 125, 20);
    _dateLabel.frame = CGRectMake(self.frame.size.width - 135, 28, 125, 20);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    // hack to avoid the background reset the UITableView does on all subviews
    [super setHighlighted:highlighted animated:animated];
    [_circleIndicator setHighlighted:highlighted animated:animated];
}

@end
