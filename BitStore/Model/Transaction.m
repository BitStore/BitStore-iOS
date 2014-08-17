//
//  Transaction.m
//  BitStore
//
//  Created by Dylan Marriott on 02/02/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "Transaction.h"
#import "Receiver.h"
#import "Address.h"

@implementation Transaction {
    NSNumber* _total;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.orgAddress = [decoder decodeObjectForKey:@"orgAddress"];
        self.hash = [decoder decodeObjectForKey:@"hash"];
        self.sender = [decoder decodeObjectForKey:@"sender"];
        self.receiver = [decoder decodeObjectForKey:@"receiver"];
        self.date = [decoder decodeObjectForKey:@"date"];
        self.confirmations = [decoder decodeIntForKey:@"confirmations"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.orgAddress forKey:@"orgAddress"];
    [encoder encodeObject:self.hash forKey:@"hash"];
    [encoder encodeObject:self.sender forKey:@"sender"];
    [encoder encodeObject:self.receiver forKey:@"receiver"];
    [encoder encodeObject:self.date forKey:@"date"];
    [encoder encodeInt:self.confirmations forKey:@"confirmations"];
}

- (BTCSatoshi)total {
    if (_total == nil) {
        BTCSatoshi total = 0;
        for (Receiver* r in self.receiver) {
            total += r.amount;
        }
        if ([self.orgAddress.address isEqualToString:self.sender]) {
            total *= -1;
        }
        _total = [NSNumber numberWithLongLong:total];
    }
    return [_total longLongValue];
}

@end
