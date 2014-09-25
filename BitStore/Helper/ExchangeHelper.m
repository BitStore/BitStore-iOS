//
//  ExchangeHelper.m
//  BitStore
//
//  Created by Dylan Marriott on 04.02.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "ExchangeHelper.h"
#import "Exchange.h"
#import "UserDefaults.h"
#import "ExchangeListener.h"
#import "RequestHelper.h"
#import "Listeners.h"
#import "SharedUser.h"

@implementation ExchangeHelper {
	Listeners* _listeners;
    Exchange* _exchange;
	NSTimer* _timer;
}

static ExchangeHelper* sharedHelper;
static int DELAY = 300;

+ (void)initialize {
    [super initialize];
    sharedHelper = [[ExchangeHelper alloc] init];
}

+ (ExchangeHelper *)instance {
    return sharedHelper;
}

- (id)init {
    if (self = [super init]) {
		_listeners = [[Listeners alloc] init];
		[self loadState];
		[self update];
		_timer = [NSTimer scheduledTimerWithTimeInterval:(DELAY)
												  target:self
												selector:@selector(update)
												userInfo:nil
												 repeats:YES];
	}
    return self;
}

#pragma mark - Public
- (void)changeCurreny:(NSString *)currency {
    _exchange.currency = currency;
    _exchange.complete = NO;
    
    // update shared user
    SharedUser* user = [UserDefaults instance].sharedUser;
    user.todayCurrency = currency;
    user.cachedPrice = nil;
    [UserDefaults instance].sharedUser = user;
    
    [self storeState];
    [self notifyListeners];
}

- (void)changeUnit:(Unit *)unit {
    _exchange.unit = unit;
    [self storeState];
    [self notifyListeners];
}

- (Unit *)currentUnit {
    return _exchange.unit;
}

#pragma mark - Private
- (NSString *)stockUrl {
    return [NSString stringWithFormat:@"https://api.bitcoinaverage.com/ticker/global/all"];
}

- (void)update {
	NSArray* urls = [NSArray arrayWithObjects:[self stockUrl], nil];
	RequestHelper* requestHelper = [[RequestHelper alloc] init];
	[requestHelper startRequestWithUrls:urls completion:^(BOOL success, NSArray* data) {
		if (success) {
			[self parseResponse:[data objectAtIndex:0]];
			_exchange.complete = YES;
			[self storeState];
			[self notifyListeners];
		}
	}];
}

- (void)parseResponse:(NSData *)data {
    NSError* error;
    _exchange.data = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
}

#pragma mark - Storage
- (void)storeState {
	[UserDefaults instance].exchange = _exchange;
}

- (void)loadState {
	_exchange = [UserDefaults instance].exchange;
    if (_exchange == nil) {
		_exchange = [[Exchange alloc] init];
        [self storeState];
    }
}

#pragma mark - Listeners
- (void)addExchangeListener:(id<ExchangeListener>)listener {
    [_listeners addListener:listener];
	[listener exchangeChanged:_exchange];
}

- (void)notifyListeners {
    [_listeners notifyListeners:^(id<ExchangeListener> listener) {
        [listener exchangeChanged:_exchange];
    }];
}

- (NSArray *)listeners {
    return [_listeners listeners];
}

@end
