//
//  SendViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 16.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "SendViewController.h"
#import "ScanNavigationController.h"
#import "ScanDelegate.h"
#import "Exchange.h"
#import "ExchangeHelper.h"
#import "ExchangeListener.h"
#import "AddressListener.h"
#import "Address.h"
#import "Lockbox.h"
#import "LTHPasscodeViewController.h"
#import "UIBAlertView.h"
#import "ContactList.h"
#import "ContactHelper.h"
#import "AccountActionButton.h"
#import <QuartzCore/QuartzCore.h>
#import "UserDefaults.h"
#import "AddressHelper.h"
#import "Unit.h"
#import "AmountView.h"
#import "AmountViewDelegate.h"
#import "HTAutocompleteTextField.h"

@interface SendViewController () <ScanDelegate, ExchangeListener, AddressListener, LTHPasscodeViewControllerDelegate, AmountViewDelegate, UITextFieldDelegate, HTAutocompleteDataSource, HTAutocompleteTextFieldDelegate>
@end

static double FEE = 10000;

@implementation SendViewController {
    HTAutocompleteTextField* _addressField;
    AmountView* _amountView;
    UILabel* _infoLabel;
    ScanNavigationController* _scanViewController;
    Exchange* _exchange;
    Address* _address;
    BOOL _showingError;
    UIAlertView* _loadingAlert;
    BTCSatoshi _satoshi;
    
    NSString* _initAddress;
    NSString* _initAmount;
}

- (id)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.title = l10n(@"send");
        Address* a = [AddressHelper instance].defaultAddress;
        [a addAddressListener:self];
        [[ExchangeHelper instance] addExchangeListener:self];
    }
    return self;
}

- (id)initWithAddress:(NSString *)address amount:(NSString *)amount {
    if (self = [self init]) {
        _initAddress = address;
        _initAmount = amount;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1.0];
    
    UIBarButtonItem* saveItem = [[UIBarButtonItem alloc] initWithTitle:l10n(@"send") style:UIBarButtonItemStyleDone target:self action:@selector(send:)];
    saveItem.enabled = NO;
    self.navigationItem.rightBarButtonItem = saveItem;

    UIBarButtonItem* cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[PiwikTracker sharedInstance] sendViews:@"Send", nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [_addressField becomeFirstResponder];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        _addressField = [[HTAutocompleteTextField alloc] initWithFrame:CGRectMake(16, 16, self.view.frame.size.width - 70, 30)];
        _addressField.placeholder = l10n(@"contact_or_btc_address");
        _addressField.autocompleteDataSource = self;
        _addressField.autoCompleteTextFieldDelegate = self;
        _addressField.autocompleteTextOffset = CGPointMake(0, -1);
        _addressField.needsClearButtonSpace = YES;
        _addressField.autocorrectionType = UITextAutocorrectionTypeNo;
        _addressField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        _addressField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _addressField.returnKeyType = UIReturnKeyNext;
        _addressField.borderStyle = UITextBorderStyleRoundedRect;
        [_addressField becomeFirstResponder];
        [cell.contentView addSubview:_addressField];

        UIButton* scanButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 44, 14, 32, 32)];
        [scanButton setImage:[UIImage imageNamed:@"scan"] forState:UIControlStateNormal];
        [scanButton addTarget:self action:@selector(scan:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:scanButton];
        
        _amountView = [[AmountView alloc] initWithDelegate:self frame:CGRectMake(0, 58, self.view.frame.size.width, 60)];
        _amountView.amountField.returnKeyType = UIReturnKeyNext;
        [cell.contentView addSubview:_amountView];
        
        UIView* divider = [[UIView alloc] initWithFrame:CGRectMake(0, 130, self.view.frame.size.width, 0.5)];
        divider.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        //[cell.contentView addSubview:divider];
        
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 134, self.view.frame.size.width - 40, 20)];
        _infoLabel.font = [UIFont systemFontOfSize:13];
        [self setDefaultInfo];
        [cell.contentView addSubview:_infoLabel];
        
        [self updateFields];
        
        if (_initAddress && _addressField.text.length == 0 && _amountView.amountField.text.length == 0) {
            [self setAddress:_initAddress amount:_initAmount];
        }
    }
    return cell;
}

- (NSString*)textField:(HTAutocompleteTextField*)textField completionForPrefix:(NSString*)prefix ignoreCase:(BOOL)ignoreCase {
    for (Address* contact in [[ContactHelper instance] contacts]) {
        if ([contact.label.lowercaseString hasPrefix:prefix.lowercaseString]) {
            return [contact.label substringFromIndex:prefix.length];
        }
    }
    return @"";
}

- (void)autoCompleteTextFieldDidAutoComplete:(HTAutocompleteTextField *)autoCompleteField {
    for (Address* contact in [[ContactHelper instance] contacts]) {
        if ([contact.label.lowercaseString isEqualToString:autoCompleteField.text.lowercaseString]) {
            autoCompleteField.text = contact.label;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _addressField) {
        [_amountView becomeFirstResponder];
    } else if (textField == _amountView.amountField) {
        [_addressField becomeFirstResponder];
    }
    return NO;
}

- (void)dismissKeyboard {
    [_addressField resignFirstResponder];
    [_amountView resignFirstResponder];
}

- (void)autocompleteTextField:(HTAutocompleteTextField *)autocompleteTextField didChangeAutocompleteText:(NSString *)autocompleteText {
    [self updateFields];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [textField setText:[textField.text stringByReplacingCharactersInRange:range withString:string]];
    [self updateFields];
    return NO;
}

- (void)updateFields {
    BOOL error = NO;
    if (_satoshi > _address.total - FEE) {
        error = YES;
        [self setErrorInfo];
    } else {
        [self setDefaultInfo];
    }

    BTCAddress* addr = [BTCAddress addressWithBase58String:[self address]];
    if (!error && addr != nil && _satoshi > 0) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (NSString *)address {
    NSString* address = _addressField.text;
    for (Address* contact in [[ContactHelper instance] contacts]) {
        if ([contact.label.lowercaseString isEqualToString:_addressField.text.lowercaseString]) {
            address = contact.address;
            break;
        }
    }
    return address;
}

- (void)setDefaultInfo {
    _showingError = NO;
    _infoLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    _infoLabel.text = [NSString stringWithFormat:l10n(@"balance_info"), [_exchange.unit valueForSatoshi:MAX(_address.total - FEE, 0)], [_exchange.unit valueForSatoshi:-FEE round:NO showUnit:NO]];
}

- (void)setErrorInfo {
    _showingError = YES;
    _infoLabel.textColor = [UIColor colorWithRed:0.58 green:0.12 blue:0.18 alpha:1.00];
    _infoLabel.text = [NSString stringWithFormat:l10n(@"balance_error"), [_exchange.unit valueForSatoshi:MAX(_address.total - FEE, 0) round:NO]];
}

- (void)scan:(id)sender {
    _scanViewController = [[ScanNavigationController alloc] initWithScanDelegate:self];
    [self presentViewController:_scanViewController animated:YES completion:nil];
}

- (void)amountValueChanged:(BTCSatoshi)satoshi {
    _satoshi = satoshi;
    [self updateFields];
}

- (void)scannedAddress:(NSString *)address amount:(NSString *)amount {
    [_scanViewController dismissViewControllerAnimated:YES completion:nil];
    [self setAddress:address amount:amount];
}

- (void)setAddress:(NSString *)address amount:(NSString *)amount {
    [self setAddressText:[[ContactHelper instance].contactList displayTextForAddress:address]];
    if (amount) {
        BTCSatoshi satoshi = [amount satoshiWithFactor:100000000.0f];
        
        NSString* newTextAmount;
        if ([UserDefaults instance].defaultPayMode == 0) {
            // BTC input
            newTextAmount = [_exchange.unit valueForSatoshi:satoshi round:YES showUnit:NO];
        } else {
            // currency input
            double val = _exchange.current * amount.doubleValue;
            newTextAmount = [NSString stringWithFormat:@"%.2f", val];
        }
        
        [_amountView setAmountText:newTextAmount];
    }
}

- (void)setAddressText:(NSString *)address {
    _addressField.text = @"";
    NSRange range = {0, 0};
    [self textField:_addressField shouldChangeCharactersInRange:range replacementString:address];
}

- (void)exchangeChanged:(Exchange *)exchange {
    _exchange = exchange;
    [self updateFields];
}

- (void)addressChanged:(Address *)address {
    _address = address;
    
    if (_showingError) {
        [self setErrorInfo];
    } else {
        [self setDefaultInfo];
    }
}

- (void)send:(id)sender {
    [LTHPasscodeViewController sharedUser].delegate = self;
    [LTHPasscodeViewController sharedUser].maxNumberOfAllowedFailedAttempts = 3;
    if ([LTHPasscodeViewController doesPasscodeExist]) {
        [[LTHPasscodeViewController sharedUser] showLockScreen:self animated:NO];
    } else {
        [self startSend];
    }
}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)maxNumberOfFailedAttemptsReached {
    [[LTHPasscodeViewController sharedUser] dismissViewControllerAnimated:YES completion:^() {
        [[LTHPasscodeViewController sharedUser] reset];
    }];
    [self cancel:self];
}

- (void)passcodeWasEnteredSuccessfully {
    [self startSend];
}

- (void)startSend {
    _loadingAlert = [[UIAlertView alloc] init];
    _loadingAlert.title = l10n(@"please_wait");
    [_loadingAlert show];
    [self performSelector:@selector(startTransaction) withObject:nil afterDelay:0.01];
}

- (void)startTransaction {
    NSArray* keys = [Lockbox arrayForKey:@"bitstore_3"];
    NSString* prv = [keys objectAtIndex:[UserDefaults instance].defaultAddressIndex];
    
    NSString* privateKey = prv;
    NSString* receiver = [self address];
    BTCSatoshi amount = _satoshi;
    
    
    NSError* error;
    BTCPrivateKeyAddress* privateAddress = [BTCAddress addressWithBase58String:privateKey];
    BTCPublicKeyAddress* recipient = [BTCPublicKeyAddress addressWithBase58String:receiver];
    BTCTransaction* transaction = [self transactionSpendingFromPrivateKey:privateAddress.data
                                                                       to:recipient
                                                                   amount:amount
                                                                      fee:FEE
                                                                    error:&error];
    
    
    BTCTransactionOutput* output = transaction.outputs[0];
    [_loadingAlert dismiss];
    UIBAlertView* av = [[UIBAlertView alloc] initWithTitle:l10n(@"verify_tx_title") message:[NSString stringWithFormat:l10n(@"verify_tx_message"), [_exchange.unit valueForSatoshi:output.value], [[ContactHelper instance].contactList displayTextForAddress:recipient.base58String]] cancelButtonTitle:l10n(@"cancel") otherButtonTitles:l10n(@"send"), nil];
    [av showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL didCancel) {
        if (!didCancel) {
            [self sendTransaction:transaction];
        }
    }];
}

- (void)sendTransaction:(BTCTransaction *)transaction {
    [_loadingAlert show];
    NSURLRequest* req = [[[BTCBlockchainInfo alloc] init] requestForTransactionBroadcastWithData:[transaction data]];
    if (req != nil) {
        [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
        [_loadingAlert dismiss];
        [_address refresh];
        
        [[PiwikTracker sharedInstance] sendEventWithCategory:@"Events" action:@"Send" name:nil value:nil];
        
        UIBAlertView* successAlert = [[UIBAlertView alloc] initWithTitle:l10n(@"success") message:l10n(@"tx_success_msg") cancelButtonTitle:l10n(@"okay") otherButtonTitles:nil];
        [successAlert showWithDismissHandler:^(NSInteger selectedIndex, NSString *selectedTitle, BOOL didCancel) {
            [self cancel:self];
        }];
    } else {
        [[PiwikTracker sharedInstance] sendExceptionWithDescription:@"Send failed" isFatal:NO];
        
        [_loadingAlert dismiss];
        UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle:l10n(@"error_title") message:l10n(@"tx_error_msg") delegate:nil cancelButtonTitle:l10n(@"okay") otherButtonTitles: nil];
        [errorAlert show];
    }
}

- (BTCTransaction *)transactionSpendingFromPrivateKey:(NSData *)privateKey
                                                   to:(BTCPublicKeyAddress *)destinationAddress
                                               amount:(BTCSatoshi)amount
                                                  fee:(BTCSatoshi)fee
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
    
    // Find enough outputs to spend the total amount.
    BTCSatoshi totalAmount = amount + fee;
    
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
        if (total >= (totalAmount)) {
            break;
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
    BTCTransactionOutput* paymentOutput = [[BTCTransactionOutput alloc] initWithValue:amount address:destinationAddress];
    BTCTransactionOutput* changeOutput = [[BTCTransactionOutput alloc] initWithValue:(spentCoins - (amount + fee)) address:key.uncompressedPublicKeyAddress];
    
    // Idea: deterministically-randomly choose which output goes first to improve privacy.
    [tx addOutput:paymentOutput];
    if (changeOutput.value > 0) {
        [tx addOutput:changeOutput];
    }
    
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


- (void)dealloc {
    [_amountView removeFromSuperview];
    _amountView = nil;
}

@end
