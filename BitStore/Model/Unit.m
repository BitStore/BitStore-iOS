//
//  Unit.m
//  BitStore
//
//  Created by Dylan Marriott on 20.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "Unit.h"

static NSArray* units;

@implementation Unit

- (id)initWithType:(UnitType)type {
    if (self = [super init]) {
        self.type = type;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		self.type = [aDecoder decodeIntegerForKey:@"type"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeInteger:self.type forKey:@"type"];
}

- (NSString *)displayName {
    NSString* ret = @"";
    switch (self.type) {
        case btc:
            ret = @"BTC";
            break;
        case mbtc:
            ret = @"mBTC";
            break;
        case ubtc:
            ret = @"μBTC";
            break;
        default:
            break;
    }
    return ret;
}

- (NSString *)technicalName {
    NSString* ret = @"";
    switch (self.type) {
        case btc:
            ret = @"btc";
            break;
        case mbtc:
            ret = @"mbtc";
            break;
        case ubtc:
            ret = @"ubtc";
            break;
        default:
            break;
    }
    return ret;
}

- (NSString *)valueForSatoshi:(BTCSatoshi)satoshi {
    return [self valueForSatoshi:satoshi round:YES];
}

- (NSString *)valueForSatoshi:(BTCSatoshi)satoshi round:(BOOL)round {
	return [self valueForSatoshi:satoshi round:round showUnit:YES];
}

- (NSString *)valueForSatoshi:(BTCSatoshi)satoshi round:(BOOL)round showUnit:(BOOL)showUnit {
    NSString* value = 0;
    NSString* unit = @"";
    double factor = [self factor];
	int decimalPlaces = 0;
    switch (self.type) {
        case btc:
			decimalPlaces = 4;
            unit = @"BTC";
            break;
        case mbtc:
			decimalPlaces = 2;
            unit = @"mBTC";
            break;
        case ubtc:
			decimalPlaces = 0;
            unit = @"μBTC";
            break;
        default:
            break;
    }
	
	if (!round) {
		decimalPlaces += 1;
	}
	
	if (decimalPlaces > 0) {
		NSString* format = [NSString stringWithFormat:@"%%.%if", decimalPlaces];
		value = [NSString stringWithFormat:format, satoshi / factor];
	} else {
		value = [NSString stringWithFormat:@"%.0f", roundf(satoshi / factor)];
	}
    
	if (!round) {
		if (decimalPlaces == 1) {
			value = [value substringToIndex:value.length - 2];
		} else {
			value = [value substringToIndex:value.length - 1];
		}
	}
	
    if (showUnit) {
        return [NSString stringWithFormat:@"%@ %@", value, unit];
    } else {
        return value;
    }
}

- (double)factor {
    long ret = 1;
    switch (self.type) {
        case btc:
            ret = 100000000.0f;
            break;
        case mbtc:
            ret = 100000.0f;
            break;
        case ubtc:
            ret = 100.0f;
            break;
        default:
            break;
    }
    return ret;
}

- (int)maxFraction {
    int maxFraction;
    
    switch (self.type) {
        case btc:
            maxFraction = 8;
            break;
        case mbtc:
            maxFraction = 5;
            break;
        case ubtc:
            maxFraction = 2;
            break;
        default:
            break;
    }

    return maxFraction;
}

- (BOOL)isEqual:(id)object {
    return self.type == ((Unit *)object).type;
}

+ (NSArray *)availableTypes {
    if (units == nil) {
        units = [NSArray arrayWithObjects:[[Unit alloc] initWithType:btc], [[Unit alloc] initWithType:mbtc], [[Unit alloc] initWithType:ubtc], nil];
    }
    return units;
}


@end
