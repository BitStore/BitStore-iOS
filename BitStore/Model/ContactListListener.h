//
//  ContactListListener.h
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactList.h"

@protocol ContactListListener <NSObject>

- (void)contactListChanged:(ContactList *)contactList;

@end
