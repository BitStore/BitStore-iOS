//
//  ExchangeHelper.h
//  BitStore
//
//  Created by Dylan Marriott on 04.02.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ExchangeListener;
@class Unit;

@interface ExchangeHelper : NSObject

+ (ExchangeHelper *)instance;

- (void)changeCurreny:(NSString *)currency;
- (void)changeUnit:(Unit *)unit;
- (Unit *)currentUnit;
- (void)addExchangeListener:(id<ExchangeListener>)listener;

@end
