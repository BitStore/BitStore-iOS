//
//  ReceiveAmountDelegate.h
//  BitStore
//
//  Created by Dylan Marriott on 26.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReceiveAmountDelegate <NSObject>

- (void)amountSelected:(BTCSatoshi)satoshi;

@end
