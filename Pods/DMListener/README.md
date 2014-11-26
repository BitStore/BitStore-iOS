# DMListener

[![Build Status](https://img.shields.io/travis/D-32/DMListener/master.svg?style=flat)](https://travis-ci.org/D-32/DMListener)
[![Version](https://img.shields.io/cocoapods/v/DMListener.svg?style=flat)](http://cocoadocs.org/docsets/DMListener)
![License](https://img.shields.io/cocoapods/l/DMListener.svg?style=flat)
[![twitter: @dylan36032](http://img.shields.io/badge/twitter-%40dylan36032-blue.svg?style=flat)](https://twitter.com/dylan36032)

Often you want to observe a model object from multiple parts in your code. KVO can work, but I find it can get a mess. Using a listener protocol for each model makes it clear what can change, and who's listening.

DMListener offers an easy way to add listeners to your classes. It takes care of deallocation, so just add any view or controller as listener :)

Take a look at the example project, or [BitStore](https://github.com/BitStore/BitStore-iOS) where I'm using this in productive code.

## Installation

DMListener is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "DMListener"

If you're not using CocoaPods you'll find the source code files inside `Pod/Classes`. 

## Usage

A model class using DMListener would look like this:

	#import <DMListener/DMListeners.h>
	
	@implementation DMDemoModel {
	    DMListeners* _listeners;
	}
	
	- (instancetype)init {
	    if (self == [super init]) {
	        _listeners = [[DMListeners alloc] init];
	    }
	    return self;
	}
	
	- (void)addListener:(id<DMDemoModelListener>)listener {
	    [_listeners addListener:listener];
	}
	
	- (void)refreshData {
	    [self performSelector:@selector(dataRefreshed) withObject:nil afterDelay:1.0];
	}
	
	- (void)dataRefreshed {
	    [_listeners notifyListeners:^(id<DMDemoModelListener> listener) {
	        [listener demoModelChanged:self];
	    }];
	}
	
	@end

And to be notified of changes just call the addListener method:

	DMDemoModel* model = [[DMDemoModel alloc] init];
	[model addListener:self];

Take a look at the example project. You'll see a demo implementation inside `DMAppDelegate.m`

To run the example project you first have to run `pod install` from the Example directory.

## Author

Dylan Marriott, info@d-32.com

## License

DMListener is available under the MIT license. See the LICENSE file for more info.

