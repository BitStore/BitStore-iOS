//
//  AmountView.m
//  BitStore
//
//  Created by Dylan Marriott on 25.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "AmountView.h"
#import "Exchange.h"
#import "ExchangeHelper.h"
#import "ExchangeListener.h"
#import "Unit.h"
#import "UserDefaults.h"
#import "AmountViewDelegate.h"

@interface AmountView () <ExchangeListener, UITextFieldDelegate>
@end

@implementation AmountView {
    Exchange* _exchange;
    BTCSatoshi _satoshi;
    __weak id<AmountViewDelegate> _delegate;
    
    UILabel* _currencyLabel;
    UISegmentedControl* _segmentedControl;
}

- (id)initWithDelegate:(id<AmountViewDelegate>)delegate frame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _delegate = delegate;
        
        self.amountField = [[UITextField alloc] initWithFrame:CGRectMake(16, 0, self.frame.size.width - 100 - (3*16), 30)];
        self.amountField.placeholder = l10n(@"amount");
        self.amountField.delegate = self;
        self.amountField.keyboardType = UIKeyboardTypeDecimalPad;
        self.amountField.borderStyle = UITextBorderStyleRoundedRect;
        [self addSubview:self.amountField];
        
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"", @"", nil]];
        _segmentedControl.frame = CGRectMake(self.frame.size.width - 116, 0, 100, 30);
        _segmentedControl.tintColor = [UIColor colorWithRed:0.33 green:0.63 blue:0.87 alpha:1.00];
        [_segmentedControl addTarget:self action:@selector(selectionChanged:) forControlEvents:UIControlEventValueChanged];
        _segmentedControl.selectedSegmentIndex = [UserDefaults instance].defaultPayMode;
        [self addSubview:_segmentedControl];
        
        _currencyLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 34, self.frame.size.width - 32, 30)];
        _currencyLabel.textColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        [self addSubview:_currencyLabel];
        
        
        [[ExchangeHelper instance] addExchangeListener:self];
    }
    return self;
}

#pragma mark - Listeners
- (void)exchangeChanged:(Exchange *)exchange {
    _exchange = exchange;
    [self updateValues];
    [self updateFields];
}

- (void)updateValues {
    [_segmentedControl setTitle:[_exchange.unit displayName] forSegmentAtIndex:0];
    [_segmentedControl setTitle:_exchange.currency forSegmentAtIndex:1];
}

- (void)updateFields {
    NSMutableString* new = [[NSMutableString alloc] initWithString:@""];
    BOOL found = NO;
    int fractionCount = 0;
    for (int i = 0; i < _amountField.text.length; i++) {
        unichar c = [_amountField.text characterAtIndex:i];
        NSString* s = [NSString stringWithCharacters:&c length:1];
        if ([s isEqualToString:@"."] || [s isEqualToString:@","]) {
            if (!found) { // max one delimiter
                [new appendString:s];
                found = YES;
                fractionCount = 0;
            }
        } else {
            if (!found || (found && fractionCount < _exchange.unit.maxFraction)) {
                [new appendString:s];
            }
            fractionCount++;
        }
    }
    _amountField.text = [new substringToIndex:MIN(new.length, 8)]; // max 8 chars
    
    if ([UserDefaults instance].defaultPayMode == 0) {
        // BTC input
        double val = _exchange.current * _amountField.text.btc;
        _currencyLabel.text = [NSString stringWithFormat:@"(%.2f %@)", val, _exchange.currency];
        _satoshi = _amountField.text.satoshi;
    } else {
        // currency input
        double val = _amountField.text.cur / _exchange.current;
        _satoshi = val * 100000000.0f;
        _currencyLabel.text = [NSString stringWithFormat:@"(%@)", [_exchange.unit valueForSatoshi:_satoshi]];
    }
}

- (void)setAmountValue:(BTCSatoshi)amount {
    if ([UserDefaults instance].defaultPayMode == 0) {
        // BTC input
        [self setAmountText:[_exchange.unit valueForSatoshi:amount round:YES showUnit:NO]];
    } else {
        // currency input
        double val = (amount / 100000000.0f) * _exchange.current;
        [self setAmountText:[NSString stringWithFormat:@"%.2f", val]];
    }
}

- (void)setAmountText:(NSString *)amount {
    _amountField.text = @"";
    NSRange range = {0, 0};
    [self textField:_amountField shouldChangeCharactersInRange:range replacementString:amount];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [textField setText:[textField.text stringByReplacingCharactersInRange:range withString:string]];
    NSString* set = @"0123456789.,";
    if (set) {
        textField.text = [[textField.text componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:set] invertedSet]] componentsJoinedByString:@""];
    }
    [self updateFields];
    [_delegate amountValueChanged:_satoshi];
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([_delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [_delegate textFieldShouldReturn:textField];
    } else {
        return NO;
    }
}


#pragma mark - Actions
- (void)selectionChanged:(id)sender {
    [UserDefaults instance].defaultPayMode = _segmentedControl.selectedSegmentIndex;
    [self updateFields];
    [_delegate amountValueChanged:_satoshi];
}

#pragma mark - UIView
- (BOOL)becomeFirstResponder {
    return [_amountField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    return [_amountField resignFirstResponder];
}

@end
