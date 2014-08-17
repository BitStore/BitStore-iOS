//
//  ContactHelper.m
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "ContactHelper.h"
#import "ContactListListener.h"
#import "UserDefaults.h"
#import "Address.h"
#import "Listeners.h"

@implementation ContactHelper {
    ContactList* _contactList;
    Listeners* _listeners;
}

static ContactHelper* sharedHelper;

+ (void)initialize {
    [super initialize];
    sharedHelper = [[ContactHelper alloc] init];
}

+ (ContactHelper *)instance {
    return sharedHelper;
}

- (id)init {
    if (self = [super init]) {
		_listeners = [[Listeners alloc] init];
		[self loadState];
		for (Address* a in _contactList.contacts) {
			[a refresh];
		}
	}
    return self;
}

- (NSArray *)contacts {
    return _contactList.contacts;
}

- (ContactList *)contactList {
    return _contactList;
}

- (void)addContact:(NSString *)name address:(NSString *)address {
    Address* add = [[Address alloc] init];
    add.address = address;
    add.label = name;
    [add refresh];
    [_contactList.contacts addObject:add];
    [self storeState];
    [self notifyListeners];
}

- (void)removeContactAtIndex:(int)index {
    [_contactList.contacts removeObjectAtIndex:index];
    [self storeState];
    [self notifyListeners];
}

- (void)addContactListListener:(id<ContactListListener>)listener {
    [_listeners addListener:listener];
    [listener contactListChanged:_contactList];
}

- (NSArray *)listeners {
    return _listeners.listeners;
}

- (void)notifyListeners {
	[_listeners notifyListeners:^(id<ContactListListener> listener) {
        [listener contactListChanged:_contactList];
    }];
}

#pragma mark - Storage
- (void)storeState {
	[UserDefaults instance].contactList = _contactList;
}

- (void)loadState {
	_contactList = [UserDefaults instance].contactList;
    if (_contactList == nil) {
		_contactList = [[ContactList alloc] init];
        [self storeState];
    }
}

@end
