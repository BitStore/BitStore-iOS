//
//  ContactList.m
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "ContactList.h"
#import "Address.h"
#import "UserDefaults.h"
#import "AddressHelper.h"

@implementation ContactList

- (id)init {
    if (self = [super init]) {
        self.contacts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.contacts = [decoder decodeObjectForKey:@"contacts"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.contacts forKey:@"contacts"];
}

- (NSString *)displayTextForAddress:(NSString *)address {
    Address* me = [AddressHelper instance].defaultAddress;
    if ([address isEqualToString:me.address]) {
        return l10n(@"me");
    }
    for (Address* a in self.contacts) {
        if ([a.address isEqualToString:address]) {
            return a.label;
        }
    }
    if ([address isEqualToString:@"1BitSTRMX1bAmqJkxovRctxgDewuwGDhRH"]) {
        return @"BitStore";
    }
    return address;
}

- (BOOL)isContact:(NSString *)address {
    NSString* a = [self displayTextForAddress:address];
    Address* me = [AddressHelper instance].defaultAddress;
    return ![address isEqualToString:a] || [address isEqualToString:me.address];
}

@end
