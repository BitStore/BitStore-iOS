//
//  Receiver.m
//  BitStore
//
//  Created by Dylan Marriott on 02/02/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "Receiver.h"

@implementation Receiver

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.address = [decoder decodeObjectForKey:@"address"];
        self.amount = [decoder decodeInt64ForKey:@"amount"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.address forKey:@"address"];
    [encoder encodeInt64:self.amount forKey:@"amount"];
}

@end
