//
//  SwipeViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 28/06/14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "SwipeViewController.h"
#import "ScanDelegate.h"
#import "ScanNavigationController.h"
#import "UIBAlertView.h"
#import "RequestHelper.h"
#import "Address.h"
#import "UserDefaults.h"
#import "AddressHelper.h"

@interface SwipeViewController () <ScanDelegate>
@end

@implementation SwipeViewController {
    ScanNavigationController* _scanViewController;
    UIAlertView* _loadingAlert;
}

- (id)init {
    if (self = [super init]) {
		self.title = l10n(@"swipe_key");
	}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem* closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(close:)];
    self.navigationItem.leftBarButtonItem = closeItem;
    
    _scanViewController = [[ScanNavigationController alloc] initWithScanDelegate:self];
    [self startScan];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[PiwikTracker sharedInstance] sendViews:@"Swipe", nil];
}

- (void)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startScan {
    [_scanViewController reset];
    [self.view addSubview:_scanViewController.view];
    [self addChildViewController:_scanViewController];
}

- (void)stopScan {
    [_scanViewController.view removeFromSuperview];
    [_scanViewController removeFromParentViewController];
}

#pragma mark - ScanDelegate
- (void)scannedAddress:(NSString *)address amount:(NSString *)amount {
    if ([address hasPrefix:@"BitStore:"]) {
        address = [address substringFromIndex:9];
    }
    
    BTCPrivateKeyAddress* addr = [BTCPrivateKeyAddress addressWithBase58String:address];
    [self stopScan];
    
    if (addr != nil && [addr isPrivateAddress]) {
        BTCKey* key = [[BTCKey alloc] initWithPrivateKeyAddress:addr];
        
        _loadingAlert = [[UIAlertView alloc] init];
        _loadingAlert.title = l10n(@"please_wait");
        [_loadingAlert show];
        
        [self performSelector:@selector(checkBalance:) withObject:key afterDelay:0.01];
    } else {
        UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:l10n(@"error") message:l10n(@"not_a_key") cancelButtonTitle:l10n(@"cancel") otherButtonTitles:l10n(@"retry"), nil];
        [av showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL didCancel) {
            if (didCancel) {
                [self close:self];
            } else {
                [self startScan];
            }
        }];
    }
}

- (void)checkBalance:(BTCKey *)key {
    RequestHelper* rh = [[RequestHelper alloc] init];
    NSString* url = [NSString stringWithFormat:@"https://blockchain.info/q/addressbalance/%@", key.uncompressedPublicKeyAddress.base58String];
	
	[rh startRequestWithUrl:url completion:^(BOOL success, NSData* data) {
		[_loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
		if (success) {
			BTCSatoshi balance = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] longLongValue];
			if (balance > 10000) {
				UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:l10n(@"swipe_key_title") message:[NSString stringWithFormat:l10n(@"swipe_key_message"), (double)balance / 100000000] cancelButtonTitle:l10n(@"cancel") otherButtonTitles:l10n(@"yes"), nil];
				[av showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL didCancel) {
					if (didCancel) {
						[self close:self];
					} else {
						[self doTransaction:key];
					}
				}];
			} else {
				UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:l10n(@"error") message:l10n(@"not_enough_funds") cancelButtonTitle:l10n(@"okay") otherButtonTitles:nil];
				[av showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL didCancel) {
					[self close:self];
				}];
			}
		} else {
			UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:l10n(@"error") message:l10n(@"could_not_fetch_balance") cancelButtonTitle:l10n(@"cancel") otherButtonTitles:l10n(@"retry"), nil];
			[av showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL didCancel) {
				if (didCancel) {
					[self close:self];
				} else {
					[self checkBalance:key];
				}
			}];
		}
	}];
}

- (void)doTransaction:(BTCKey *)key {
    [_loadingAlert show];
    
    Address* addr = [AddressHelper instance].defaultAddress;
    
    NSError* error;
    BTCTransaction* transaction = [self transactionSpendingFromPrivateKey:key.privateKey
                                                                       to:[BTCPublicKeyAddress addressWithBase58String:addr.address ]
                                                                    error:&error];
    
    if (error == nil) {
        NSURLRequest* req = [[[BTCBlockchainInfo alloc] init] requestForTransactionBroadcastWithData:[transaction data]];
        [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:&error];
    }
    
    [_loadingAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    if (error == nil) {
        [addr refresh];
        
        UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:l10n(@"success") message:l10n(@"swipe_success") cancelButtonTitle:l10n(@"okay") otherButtonTitles:nil];
        [av showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL didCancel) {
            [self close:self];
        }];
    } else {
        UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:l10n(@"error") message:l10n(@"swipe_failed") cancelButtonTitle:l10n(@"okay") otherButtonTitles:nil];
        [av showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL didCancel) {
            [self close:self];
        }];
    }
}

// TODO refactor this, sending should be done somewhere central
- (BTCTransaction *)transactionSpendingFromPrivateKey:(NSData *)privateKey
                                                   to:(BTCPublicKeyAddress *)destinationAddress
                                                error:(NSError**)errorOut {
    
    BTCKey* key = [[BTCKey alloc] initWithPrivateKey:privateKey];
    BTCBlockchainInfo* bci = [[BTCBlockchainInfo alloc] init];
    
    if (key.uncompressedPublicKeyAddress == nil) {
        // public key not valid
        return nil;
    }
    
    NSError* error = nil;
    NSArray* utxos = [bci unspentOutputsWithAddresses:@[ key.uncompressedPublicKeyAddress ] error:&error];
    
    if (!utxos) {
        *errorOut = error;
        return nil;
    }
    
    // Sort utxo in order of
    utxos = [utxos sortedArrayUsingComparator:^(BTCTransactionOutput* obj1, BTCTransactionOutput* obj2) {
        if ((obj1.value - obj2.value) < 0) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
    
    NSMutableArray* txouts = [[NSMutableArray alloc] init];
    long total = 0;
    
    for (BTCTransactionOutput* txout in utxos) {
        if (txout.script.isHash160Script) {
            [txouts addObject:txout];
            total += txout.value;
        }
    }
    
    // Create a new transaction
    BTCTransaction* tx = [[BTCTransaction alloc] init];
    BTCSatoshi spentCoins = 0;
    
    // Add all outputs as inputs
    for (BTCTransactionOutput* txout in txouts) {
        BTCTransactionInput* txin = [[BTCTransactionInput alloc] init];
        txin.previousHash = txout.transactionHash;
        txin.previousIndex = txout.index;
        [tx addInput:txin];
        spentCoins += txout.value;
    }
    
    // Add required outputs - payment and change
    BTCTransactionOutput* paymentOutput = [[BTCTransactionOutput alloc] initWithValue:(total - 10000) address:destinationAddress];
    
    // Idea: deterministically-randomly choose which output goes first to improve privacy.
    [tx addOutput:paymentOutput];
    
    // Sign all inputs. We now have both inputs and outputs defined, so we can sign the transaction.
    for (int i = 0; i < txouts.count; i++) {
        // Normally, we have to find proper keys to sign this txin, but in this
        // example we already know that we use a single private key.
        
        BTCTransactionOutput* txout = txouts[i];
        BTCTransactionInput* txin = tx.inputs[i];
        BTCScript* sigScript = [[BTCScript alloc] init];
        NSData* d1 = tx.data;
        NSData* hash = [tx signatureHashForScript:txout.script inputIndex:i hashType:BTCSignatureHashTypeAll error:errorOut];
        NSData* d2 = tx.data;
        
        NSAssert([d1 isEqual:d2], @"Transaction must not change within signatureHashForScript!");
        
        if (!hash) {
            return nil;
        }
        
        NSData* signature = [key signatureForHash:hash];
        
        NSMutableData* signatureForScript = [signature mutableCopy];
        unsigned char hashtype = BTCSignatureHashTypeAll;
        [signatureForScript appendBytes:&hashtype length:1];
        [sigScript appendData:signatureForScript];
        [sigScript appendData:key.publicKey];
        
        NSAssert([key isValidSignature:signature hash:hash], @"Signature must be valid");
        txin.signatureScript = sigScript;
    }
    
    {
        BTCScriptMachine* sm = [[BTCScriptMachine alloc] initWithTransaction:tx inputIndex:0];
        NSError* error = nil;
        BOOL r = [sm verifyWithOutputScript:[[(BTCTransactionOutput*)txouts[0] script] copy] error:&error];
        NSLog(@"Error: %@", error);
        NSAssert(r, @"should verify first output");
    }
    
    return tx;
}


@end
