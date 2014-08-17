//
//  ContactList.h
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactList : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray* contacts;

- (NSString *)displayTextForAddress:(NSString *)address;
- (BOOL)isContact:(NSString *)address;

@end
