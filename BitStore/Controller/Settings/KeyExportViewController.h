//
//  KeyExportViewController.h
//  BitStore
//
//  Created by Dylan Marriott on 28/06/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyExportViewController : UIViewController

- (id)initWithPrivateKey:(NSString *)privateKey index:(int)index showTrash:(BOOL)showTrash;

@end
