//
//  DebugViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 11/07/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "DebugViewController.h"
#import "ExchangeHelper.h"
#import "Address.h"
#import "UserDefaults.h"
#import "ContactHelper.h"
#import "ContactList.h"
#import "AddressHelper.h"
#import "QRHelper.h"
#import "Lockbox.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

@implementation DebugViewController {
    NSArray* _exchangeListeners;
    NSArray* _mainAddressListeners;
    NSArray* _contactListeners;
}

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    self.title = @"Debug";
    _exchangeListeners = [[ExchangeHelper instance] performSelector:@selector(listeners) withObject:nil];
    _mainAddressListeners = [[AddressHelper instance] performSelector:@selector(listeners) withObject:nil];
    _contactListeners = [[ContactHelper instance] performSelector:@selector(listeners) withObject:nil];
    
    UIBarButtonItem* refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    self.navigationItem.rightBarButtonItem = refreshItem;
    
    return self;
}

- (void)refresh {
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return _exchangeListeners.count;
    } else if (section == 2) {
        return _mainAddressListeners.count;
    } else if (section == 3) {
        return _contactListeners.count;
    } else if (section == 4) {
        return [ContactHelper instance].contacts.count;
    } else if (section == 5) {
        return 2;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"About";
    } else if (section == 1) {
        return [NSString stringWithFormat:@"Exchange (%lu)", (unsigned long)_exchangeListeners.count];
    } else if (section == 2) {
        return [NSString stringWithFormat:@"Main Address (%lu)", (unsigned long)_mainAddressListeners.count];
    } else if (section == 3) {
        return [NSString stringWithFormat:@"Contact List (%lu)", (unsigned long)_contactListeners.count];
    } else if (section == 4) {
        return [NSString stringWithFormat:@"Contacts"];
    } else if (section == 5) {
        return [NSString stringWithFormat:@"Keys"];
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 5 && indexPath.row == 0) {
        return 270;
    } else {
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"Version %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Copyright 2014 Dylan Marriott";
        }
    } else if (indexPath.section == 1) {
        id<NSObject> obj = [_exchangeListeners objectAtIndex:indexPath.row];
        cell.textLabel.text = [obj description];
    } else if (indexPath.section == 2) {
        id<NSObject> obj = [_mainAddressListeners objectAtIndex:indexPath.row];
        cell.textLabel.text = [obj description];
    } else if (indexPath.section == 3) {
        id<NSObject> obj = [_contactListeners objectAtIndex:indexPath.row];
        cell.textLabel.text = [obj description];
    } else if (indexPath.section == 4) {
        Address* a = [[[ContactHelper instance] contacts] objectAtIndex:indexPath.row];
        NSString* display = a.label;
        if (display == nil) {
            display = a.address;
        }
        display = [display substringToIndex:MIN(10, display.length)];
        NSArray* listeners = [a performSelector:@selector(listeners) withObject:nil];
        cell.textLabel.text = [NSString stringWithFormat:@"%@: %lu", display, (unsigned long)listeners.count];
    } else if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            NSDictionary* oldKey = [Lockbox dictionaryForKey:@"bitstore" sync:YES];
            CGFloat qrWidth = 200;
            UIImage* qrCodeImage = [QRHelper qrcode:[oldKey objectForKey:@"private"] withDimension:qrWidth];
            UIImageView* qrCode = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - qrWidth / 2, 10, qrWidth, qrWidth)];
            qrCode.image = qrCodeImage;
            [cell.contentView addSubview:qrCode];
            
            UITextView* keyLabel = [[UITextView alloc] initWithFrame:CGRectMake(40, qrWidth + 10, self.view.frame.size.width - 80, 50)];
            keyLabel.text = [oldKey objectForKey:@"private"];
            keyLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
            keyLabel.font = [UIFont systemFontOfSize:12];
            keyLabel.editable = NO;
            keyLabel.scrollEnabled = NO;
            keyLabel.textAlignment = NSTextAlignmentCenter;
            [cell.contentView addSubview:keyLabel];
        } else {
            cell.textLabel.text = @"Delete all private keys (really?)";
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 5 && indexPath.row == 1) {
        [Lockbox setString:nil forKey:@"bitstore"];
        [Lockbox setString:nil forKey:@"bitstore_2"];
        [Lockbox setString:nil forKey:@"bitstore_3"];
    }
}

#pragma clang diagnostic pop

@end
