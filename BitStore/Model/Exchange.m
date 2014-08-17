//
//  ExchangeState.m
//  BitStore
//
//  Created by Dylan Marriott on 04.02.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "Exchange.h"
#import "Unit.h"

@implementation Exchange

- (id)init {
	if (self = [super init]) {
		self.complete = NO;
		self.currency = @"USD";
		self.data = nil;
        self.unit = [[Unit alloc] initWithType:btc];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.complete = [decoder decodeBoolForKey:@"complete"];
		self.currency = [decoder decodeObjectForKey:@"currency"];
		self.data = [decoder decodeObjectForKey:@"data"];
        self.unit = [decoder decodeObjectForKey:@"unit"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeBool:self.complete forKey:@"complete"];
	[encoder encodeObject:self.currency forKey:@"currency"];
	[encoder encodeFloat:self.current forKey:@"current"];
	[encoder encodeObject:self.data forKey:@"data"];
    [encoder encodeObject:self.unit forKey:@"unit"];
}

- (float)current {
    return [self valueForCurrency:self.currency];
}

- (float)valueForCurrency:(NSString *)currency {
    return [[[self.data objectForKey:currency] objectForKey:@"last"] floatValue];
}

- (Unit *)unit {
    if (_unit == nil) {
        _unit = [[Unit alloc] initWithType:btc];
    }
    return _unit;
}

@end
