//
//  Order.h
//  BitStore
//
//  Created by Dylan Marriott on 10.08.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Order : NSObject

- (id)initWithOrderId:(NSString *)orderId amount:(int)amount price:(float)price;

@property (nonatomic) NSString* orderId;
@property (nonatomic) int amount;
@property (nonatomic) float price;
@property (nonatomic) NSString* phoneNumber;
@property (nonatomic) NSString* token;
@property (nonatomic) NSString* fingerprint;

@end
