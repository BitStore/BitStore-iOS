//
//  AmountViewDelegate.h
//  BitStore
//
//  Created by Dylan Marriott on 25.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AmountViewDelegate <NSObject>

- (void)amountValueChanged:(BTCSatoshi)satoshi;

@optional
- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end
