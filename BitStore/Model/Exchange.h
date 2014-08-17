//
//  ExchangeState.h
//  BitStore
//
//  Created by Dylan Marriott on 04.02.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Unit;

@interface Exchange : NSObject <NSCoding>

@property (nonatomic) BOOL complete;
@property (nonatomic) NSString* currency;
@property (nonatomic, readonly) float current;
@property (nonatomic) NSDictionary* data;
@property (nonatomic) Unit* unit;

- (float)valueForCurrency:(NSString *)currency;

@end
