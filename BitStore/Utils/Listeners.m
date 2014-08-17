//
//  Listeners.m
//  BitStore
//
//  Created by Dylan Marriott on 26.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "Listeners.h"
#import "WeakRef.h"

@implementation Listeners {
    NSMutableArray* _listeners;
}

- (id)init {
    if (self = [super init]) {
        _listeners = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addListener:(id)listener {
    WeakRef* weakRef = [[WeakRef alloc] initWithObject:listener];
    [_listeners addObject:weakRef];
}

- (void)notifyListeners:(NotifyBlock)notifyBlock {
    NSArray* copy = [NSArray arrayWithArray:_listeners];
	for (WeakRef* ref in copy) {
        id obj = ref.ref;
        if (obj == nil) {
            [_listeners removeObject:ref];
        }
        notifyBlock(obj);
	}
}

- (NSArray *)listeners {
    [self cleanListeners];
    return _listeners;
}

- (void)cleanListeners {
    NSMutableArray* discard = [NSMutableArray array];
    for (WeakRef* ref in _listeners) {
        if (ref.ref == nil) {
            [discard addObject:ref];
        }
    }
    
    [_listeners removeObjectsInArray:discard];
}

@end
