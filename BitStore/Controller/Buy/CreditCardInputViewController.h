//
//  CreditCardInputViewController.h
//  BitStore
//
//  Created by Dylan Marriott on 26.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Order;

@interface CreditCardInputViewController : UITableViewController

- (id)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithStyle:(UITableViewStyle)style UNAVAILABLE_ATTRIBUTE;
- (id)initWithOrder:(Order *)order;

@end
