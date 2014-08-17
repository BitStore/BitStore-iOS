//
//  Transaction.h
//  BitStore
//
//  Created by Dylan Marriott on 02/02/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Address;

@interface Transaction : NSObject <NSCoding>

@property (nonatomic, assign) Address* orgAddress;
@property (nonatomic, strong) NSString* hash;
@property (nonatomic, strong) NSString* sender;
@property (nonatomic, strong) NSArray* receiver; // with Receiver (ex. sender addr)
@property (nonatomic, strong) NSDate* date;
@property (nonatomic, assign) int confirmations;

- (BTCSatoshi)total;

@end
