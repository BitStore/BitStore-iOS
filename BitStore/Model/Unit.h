//
//  Unit.h
//  BitStore
//
//  Created by Dylan Marriott on 20.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    btc,
    mbtc,
    ubtc
} UnitType;

@interface Unit : NSObject <NSCoding>

@property (nonatomic) UnitType type;

- (id)initWithType:(UnitType)type;
- (NSString *)displayName;
- (NSString *)technicalName;
- (NSString *)valueForSatoshi:(BTCSatoshi)satoshi;
- (NSString *)valueForSatoshi:(BTCSatoshi)satoshi round:(BOOL)round;
- (NSString *)valueForSatoshi:(BTCSatoshi)satoshi round:(BOOL)round showUnit:(BOOL)showUnit;
- (double)factor;
- (int)maxFraction;

+ (NSArray *)availableTypes; // returns Unit

@end
