//
//  DMListeners.h
//  Pods
//
//  Created by Dylan Marriott on 04/11/14.
//
//

#import <Foundation/Foundation.h>

typedef void(^NotifyBlock)(id obj);

/**
 *  DMListeners manages the list of listeners and provides methods for adding new listeners and notifying them.
 *  Deallocated listeners will be automatically removed.
 */
@interface DMListeners : NSObject

/**
 *  Add a new listener
 *
 *  @param listener listener to add
 */
- (void)addListener:(id)listener;

/**
 *  Notify all listeners. The notifyBlock will be called for each still allocated listener.
 *
 *  @param notifyBlock block that will be called for each listener
 */
- (void)notifyListeners:(NotifyBlock)notifyBlock;

/**
 *  Returns all still allocated listeners.
 *
 *  @return all still allocated listeners
 */
- (NSArray *)listeners;

@end
