//
//  AmountView.h
//  BitStore
//
//  Created by Dylan Marriott on 25.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AmountViewDelegate;

@interface AmountView : UIView

@property (nonatomic) UITextField* amountField;

- (id)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
- (id)initWithDelegate:(id<AmountViewDelegate>)delegate frame:(CGRect)frame;
- (void)setAmountValue:(BTCSatoshi)amount;
- (void)setAmountText:(NSString *)amount;

@end
