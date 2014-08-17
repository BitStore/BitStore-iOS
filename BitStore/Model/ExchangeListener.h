//
//  ExchangeListener.h
//  BitStore
//
//  Created by Dylan Marriott on 04.02.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Exchange.h"

@protocol ExchangeListener <NSObject>

- (void)exchangeChanged:(Exchange *)exchange;

@end
