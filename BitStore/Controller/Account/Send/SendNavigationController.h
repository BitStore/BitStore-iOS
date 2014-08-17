//
//  SendNavigationController.h
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendNavigationController : UINavigationController

- (id)initWithAddress:(NSString *)address amount:(NSString *)amount;

@end
