//
//  ReceiveAmountViewController.h
//  BitStore
//
//  Created by Dylan Marriott on 26.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReceiveAmountDelegate;

@interface ReceiveAmountViewController : UIViewController

- (id)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithDelegate:(id<ReceiveAmountDelegate>)delegate;
- (id)initWithDelegate:(id<ReceiveAmountDelegate>)delegate amount:(BTCSatoshi)amount;

@end
