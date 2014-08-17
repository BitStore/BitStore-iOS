//
//  BlockchainViewController.m
//  BitStore
//
//  Created by Dylan Marriott on 17.06.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#import "BlockchainViewController.h"
#import "Transaction.h"

@implementation BlockchainViewController {
    Transaction* _transaction;
}

- (id)initWithTransaction:(Transaction *)transaction {
    if (self = [super init]) {
	    _transaction = transaction;
		self.title = l10n(@"transaction");
	}
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[PiwikTracker sharedInstance] sendViews:@"Blockchain", nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIWebView* webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    NSString* url = [NSString stringWithFormat:@"https://blockchain.info/tx/%@", _transaction.hash];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [self.view addSubview:webView];
}


@end
