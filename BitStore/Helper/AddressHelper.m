//
//  AddressHelper.m
//  BitStore
//
//  Created by Dylan Marriott on 08.02.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "AddressHelper.h"
#import "UserDefaults.h"
#import "Address.h"
#import "AddressHelperListener.h"
#import "AddressListener.h"
#import "Listeners.h"

@interface AddressHelper () <AddressListener>
@end

@implementation AddressHelper {
    Listeners* _listeners;
    NSMutableArray* _addresses;
}

static AddressHelper* sharedHelper;

+ (void)initialize {
    [super initialize];
    sharedHelper = [[AddressHelper alloc] init];
}

+ (AddressHelper *)instance {
    return sharedHelper;
}

- (id)init {
    if (self = [super init]) {
	    [self loadState];
		_listeners = [[Listeners alloc] init];
	}
    return self;
}

- (NSArray *)addresses {
    return _addresses;
}

- (Address *)defaultAddress {
    if (_addresses.count == 0) {
        return nil;
    }
    if ([UserDefaults instance].defaultAddressIndex > _addresses.count - 1) {
        [UserDefaults instance].defaultAddressIndex = _addresses.count - 1;
    }
    return [_addresses objectAtIndex:[UserDefaults instance].defaultAddressIndex];
}

- (void)setDefaultAddress:(NSInteger)index {
    [UserDefaults instance].defaultAddressIndex = index;
    [self notifyListeners];
}

#pragma mark - Add / Remove
- (void)addAddress:(Address *)address {
    [_addresses addObject:address];
    [self storeState];
}

- (void)removeAddress:(Address *)address {
    [_addresses removeObject:address];
    [self storeState];
}

#pragma mark - Listener
- (void)addAddressHelperListener:(id<AddressHelperListener>)listener {
    [_listeners addListener:listener];
    [listener defaultAddressChanged:[self defaultAddress]];
}

- (NSArray *)listeners {
    return _listeners.listeners;
}

- (void)notifyListeners {
    [_listeners notifyListeners:^(id<AddressHelperListener> listener) {
        [listener defaultAddressChanged:[self defaultAddress]];
    }];
}

#pragma mark - Storage
- (void)storeState {
	[UserDefaults instance].addresses = _addresses;
}

- (void)loadState {
	_addresses = [NSMutableArray arrayWithArray:[UserDefaults instance].addresses];
    for (Address* addr in _addresses) {
        [addr addAddressListener:self];
    }
}

#pragma mark - AddressDelegate
- (void)addressChanged:(Address *)address {
    [self storeState];
}

@end
