//
//  PhoneInputViewController.h
//  BitStore
//
//  Created by Dylan Marriott on 10.08.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Order;

@interface PhoneInputViewController : UITableViewController

- (id)initWithOrder:(Order *)order country:(NSString *)country;

@end
