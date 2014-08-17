//
//  Order.m
//  BitStore
//
//  Created by Dylan Marriott on 10.08.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "Order.h"

@implementation Order

- (id)initWithOrderId:(NSString *)orderId amount:(int)amount price:(float)price {
    if (self = [super init]) {
        self.orderId = orderId;
        self.amount = amount;
        self.price = price;
    }
    return self;
}

@end
