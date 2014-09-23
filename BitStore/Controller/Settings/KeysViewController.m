//
//  KeysViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 22.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "KeysViewController.h"
#import "Lockbox.h"
#import "KeyExportViewController.h"
#import "UserDefaults.h"
#import "ScanNavigationController.h"
#import "ScanDelegate.h"
#import "AddressHelper.h"
#import "Address.h"

@interface KeysViewController () <ScanDelegate>
@end

@implementation KeysViewController {
    NSMutableArray* _keys;
    ScanNavigationController* _scanViewController;
}

- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    [self updateValues];
    self.title = l10n(@"private_keys");
	
    UIBarButtonItem* addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    self.navigationItem.rightBarButtonItem = addItem;
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateValues];
    
//    BTCKey* k = [_keys objectAtIndex:[UserDefaults instance].defaultKey];
//    NSString* currentPublic = k.publicKeyAddress.base58String;
//    if (![[AddressHelper instance].address.address isEqualToString:currentPublic]) {
//        // different address selected, update address
//        Address* addr = [AddressHelper instance].address;
//        addr.address = currentPublic;
//        [addr refresh];
//        [[AddressHelper instance] addAddress:addr];
//    }
}

- (void)updateValues {
    _keys = [[NSMutableArray alloc] init];
    for (NSString* privateKey in [Lockbox arrayForKey:@"bitstore_3"]) {
        BTCKey* k = [[BTCKey alloc] initWithPrivateKeyAddress:[BTCPrivateKeyAddress addressWithBase58String:privateKey]];
        [_keys addObject:k];
    }
    [self.tableView reloadData];
}

- (void)add:(id)sender {
    _scanViewController = [[ScanNavigationController alloc] initWithScanDelegate:self];
    [self presentViewController:_scanViewController animated:YES completion:nil];
}

- (void)scannedAddress:(NSString *)address amount:(NSString *)amount {
    [_scanViewController dismissViewControllerAnimated:YES completion:nil];
    BTCAddress* btcaddr = [BTCAddress addressWithBase58String:address];
    BTCKey* k;
    if ([btcaddr isPrivateAddress]) {
        k = [[BTCKey alloc] initWithPrivateKeyAddress:(BTCPrivateKeyAddress *)btcaddr];
        if (k != nil) {
            [Lockbox setArray:[[Lockbox arrayForKey:@"bitstore_3"] arrayByAddingObject:k.privateKeyAddress.base58String] forKey:@"bitstore_3"];
            Address* addr = [[Address alloc] init];
            addr.address = k.uncompressedPublicKeyAddress.base58String;
            [addr refresh];
            [[AddressHelper instance] addAddress:addr];
            [self updateValues];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _keys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@""];
    BTCKey* key = [_keys objectAtIndex:indexPath.row];
    NSString* text = key.uncompressedPublicKeyAddress.base58String;
    if (indexPath.row == [UserDefaults instance].defaultAddressIndex) {
        text = [NSString stringWithFormat:@"\u2606 %@", text];
    }
    cell.textLabel.text = text;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BTCKey* key = [_keys objectAtIndex:indexPath.row];
    KeyExportViewController* vc = [[KeyExportViewController alloc] initWithPrivateKey:key.privateKeyAddress.base58String index:indexPath.row showTrash:(_keys.count > 1)];
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

@end
