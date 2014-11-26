//
//  DMListeners.m
//  Pods
//
//  Created by Dylan Marriott on 04/11/14.
//
//

#import "DMListeners.h"
#import "DMWeakRef.h"

@implementation DMListeners {
    NSMutableArray* _listeners;
}

- (id)init {
    if (self = [super init]) {
        _listeners = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addListener:(id)listener {
    DMWeakRef* weakRef = [[DMWeakRef alloc] initWithObject:listener];
    [_listeners addObject:weakRef];
}

- (void)notifyListeners:(NotifyBlock)notifyBlock {
    NSArray* copy = [NSArray arrayWithArray:_listeners];
    dispatch_async(dispatch_get_main_queue(), ^{
        for (DMWeakRef* ref in copy) {
            id obj = ref.ref;
            if (obj == nil) {
                [_listeners removeObject:ref];
            }
            notifyBlock(obj);
        }
    });
}

- (NSArray *)listeners {
    [self cleanListeners];
    return _listeners;
}

- (void)cleanListeners {
    NSMutableArray* discard = [NSMutableArray array];
    for (DMWeakRef* ref in _listeners) {
        if (ref.ref == nil) {
            [discard addObject:ref];
        }
    }
    [_listeners removeObjectsInArray:discard];
}

- (NSString *)description {
    return [_listeners description];
}

@end
