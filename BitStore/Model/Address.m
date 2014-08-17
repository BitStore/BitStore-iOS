//
//  Address.m
//  BitStore
//
//  Created by Dylan Marriott on 01.02.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "Address.h"
#import "AddressListener.h"
#import "RequestHelper.h"
#import "Transaction.h"
#import "Receiver.h"
#import "MessageHelper.h"
#import "UserDefaults.h"
#import "Listeners.h"

@implementation Address {
    Listeners* _listeners;
    NSTimer* _timer;
}

- (id)init {
    if (self = [super init]) {
        _listeners = [[Listeners alloc] init];
        self.total = -1;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [self init]) {
		self.address = [decoder decodeObjectForKey:@"address"];
        self.label = [decoder decodeObjectForKey:@"label"];
        self.total = [decoder decodeInt64ForKey:@"total_2"];
        self.transactions = [decoder decodeObjectForKey:@"transactions"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
	[encoder encodeObject:self.address forKey:@"address"];
    [encoder encodeObject:self.label forKey:@"label"];
    [encoder encodeInt64:self.total forKey:@"total_2"];
    [encoder encodeObject:self.transactions forKey:@"transactions"];
}

#pragma mark - Public
- (void)addAddressListener:(id<AddressListener>)listener {
    [_listeners addListener:listener];
    [listener addressChanged:self];
}

- (NSArray *)listeners {
    return _listeners.listeners;
}

- (void)notifyListeners {
	[_listeners notifyListeners:^(id<AddressListener> listener) {
        [listener addressChanged:self];
    }];
}

- (void)refresh {
    [self refresh:NO];
}

- (void)refresh:(BOOL)showError {
    [self update:YES showError:showError];
}

- (void)startUpdate:(int)refreshRate {
    _timer = [NSTimer scheduledTimerWithTimeInterval:(refreshRate)
                                              target:self
                                            selector:@selector(updateMeta)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)stopUpdate {
    [_timer invalidate];
    _timer = nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", self.label, self.address];
}

#pragma mark - Private
- (void)updateMeta {
    [self update:NO showError:NO];
}

- (void)update:(BOOL)full showError:(BOOL)showError {
    NSString* addrUrl = [NSString stringWithFormat:@"https://api.chain.com/v1/bitcoin/addresses/%@?key=%@", self.address, [Keys chainKey]];
    NSString* txUrl = [NSString stringWithFormat:@"https://api.chain.com/v1/bitcoin/addresses/%@/transactions?key=%@&limit=20", self.address, [Keys chainKey]];
    
    NSMutableArray* urls = [[NSMutableArray alloc] init];
    [urls addObject:addrUrl];
    if (full) {
        [urls addObject:txUrl];
    }
    
	RequestHelper* rh = [[RequestHelper alloc] init];
	[rh startRequestWithUrls:urls completion:^(BOOL success, NSArray* data) {
		if (success) {
			[self parseAddressJson:[data objectAtIndex:0]];
			if (urls.count > 1) {
				[self parseTransactionsJson:[data objectAtIndex:1]];
			}
			[self notifyListeners];
		} else {
			if (showError) {
				[MessageHelper showMessage:l10n(@"network_error")];
			}
			[self notifyListeners];
		}
	}];
}

- (void)parseAddressJson:(NSData *)data {
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    self.total = [[json objectForKey:@"balance"] longValue] + [[json objectForKey:@"unconfirmed_balance"] longValue];
}

- (void)parseTransactionsJson:(NSData *)data {
    NSError* error;
    NSArray* txs = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	
    NSMutableArray* transactions = [[NSMutableArray alloc] init];
    for (NSDictionary* tx in txs) {
        if ([tx isKindOfClass:[NSDictionary class]]) {
            Transaction* transaction = [[Transaction alloc] init];
            transaction.hash = [tx objectForKey:@"hash"];
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
            if ([tx objectForKey:@"block_time"] == [NSNull null]) {
                // tx is not yet in blockchain, chain.com just returns null here
                // we have our own cache, where we store the date when it first appeared for us
                // good enough i guess
                NSMutableDictionary* cache = [UserDefaults instance].txcache;
                NSDate* d = [cache objectForKey:transaction.hash];
                if (d == nil) {
                    d = [[NSDate alloc] init];
                    [cache setObject:d forKey:transaction.hash];
                    [UserDefaults instance].txcache = cache; // stores the cache again
                }
                transaction.date = d;
            } else {
                NSTimeInterval timeZoneOffset = [[NSTimeZone defaultTimeZone] secondsFromGMT]; // You could also use the systemTimeZone method
                NSTimeInterval gmtTimeInterval = [[dateFormatter dateFromString:[tx objectForKey:@"block_time"]] timeIntervalSinceReferenceDate] + timeZoneOffset;
                transaction.date = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
                NSMutableDictionary* cache = [UserDefaults instance].txcache;
                [cache removeObjectForKey:transaction.hash];
                [UserDefaults instance].txcache = cache; // stores the cache again
            }
            
            transaction.confirmations = [[tx objectForKey:@"confirmations"] intValue];
            NSDictionary* senderDict = [[tx objectForKey:@"inputs"] objectAtIndex:0];
            transaction.sender = [[senderDict objectForKey:@"addresses"] objectAtIndex:0];
            NSMutableArray* receivers = [[NSMutableArray alloc] init];
            for (NSDictionary* receiverDict in [tx objectForKey:@"outputs"]) {
                NSString* address = [[receiverDict objectForKey:@"addresses"] objectAtIndex:0];
                if (![address isEqualToString:transaction.sender]) {
                    Receiver* receiver = [[Receiver alloc] init];
                    receiver.address = address;
                    if ([transaction.sender isEqualToString:self.address] ||
                        (![transaction.sender isEqualToString:self.address] && [address isEqualToString:self.address])) {
                        // if you're the sender, add all outputs together
                        // if you're not the sender, only add if you're the receiver
                        receiver.amount += [[receiverDict objectForKey:@"value"] longValue];
                    }
                    [receivers addObject:receiver];
                }
            }
            if (receivers.count == 0) {
                NSDictionary* receiverDict = [[tx objectForKey:@"outputs"] objectAtIndex:0];
                NSString* address = [[receiverDict objectForKey:@"addresses"] objectAtIndex:0];
                Receiver* receiver = [[Receiver alloc] init];
                receiver.address = address;
                receiver.amount += [[receiverDict objectForKey:@"value"] longValue];
                [receivers addObject:receiver];
            }
            transaction.receiver = receivers;
            transaction.orgAddress = self;
            [transactions addObject:transaction];
        }
    }
    self.transactions = transactions;
}


@end
