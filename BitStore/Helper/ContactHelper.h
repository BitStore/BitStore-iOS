//
//  ContactHelper.h
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactListListener.h"

@interface ContactHelper : NSObject

+ (ContactHelper *)instance;
- (NSArray *)contacts;
- (ContactList *)contactList;
- (void)addContact:(NSString *)name address:(NSString *)address;
- (void)removeContactAtIndex:(int)index;

- (void)addContactListListener:(id<ContactListListener>)listener;

@end
