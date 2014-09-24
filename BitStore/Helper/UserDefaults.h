//
//  UserDefaults.h
//  BitStore
//
//  Created by Dylan Marriott on 04.02.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Exchange;
@class Address;
@class ContactList;
@class SharedUser;

@interface UserDefaults : NSObject

@property (nonatomic) Exchange* exchange;
@property (nonatomic) NSArray* addresses; // Address
@property (nonatomic) NSInteger defaultAddressIndex;
@property (nonatomic) ContactList* contactList;
@property (nonatomic) NSInteger version;
@property (nonatomic) BOOL pushActive;
@property (nonatomic) NSInteger defaultPayMode; // 0 = BTC, 1 = currency
@property (nonatomic) NSMutableDictionary* txcache;
@property (nonatomic) NSArray* jobs;
@property (nonatomic) NSString* userId;
@property (nonatomic) BOOL buyEnabled;
@property (nonatomic) BOOL buyShowed;
@property (nonatomic) BOOL buyDismissed;
@property (nonatomic) NSString* customerId;
@property (nonatomic) SharedUser* sharedUser;

+ (UserDefaults *)instance;
- (void)reset;

@end
