//
//  Listeners.h
//  BitStore
//
//  Created by Dylan Marriott on 26.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^NotifyBlock)(id obj);

@interface Listeners : NSObject

- (void)addListener:(id)listener;
- (void)notifyListeners:(NotifyBlock)notifyBlock;
- (NSArray *)listeners;

@end
