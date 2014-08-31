//
//  Balanced.h
//  Balanced iOS
//
//  Created by Ben Mills on 3/9/13.
//

#import <Foundation/Foundation.h>
#import "BPCard.h"
#import "BPBankAccount.h"

__unused static NSString *BalancedResponseBrandKey = @"brand";
__unused static NSString *BalancedResponseCardTypeKey = @"card_type";
__unused static NSString *BalancedResponseHashKey = @"hash";
__unused static NSString *BalancedResponseIdKey = @"id";
__unused static NSString *BalancedResponseIsValidKey = @"is_valid";
__unused static NSString *BalancedResponseUriKey = @"uri";

typedef void (^BalancedTokenizeResponseBlock)(NSDictionary *responseParams);
typedef void (^BalancedErrorBlock)(NSError *error);

typedef NS_ENUM(NSUInteger, BPFundingInstrumentType)
{
    BPFundingInstrumentTypeCard,
    BPFundingInstrumentTypeBankAccount
};

@interface Balanced : NSObject <NSURLConnectionDelegate>
- (void)createCardWithNumber:(NSString *)number
             expirationMonth:(NSUInteger)expMonth
              expirationYear:(NSUInteger)expYear
                   onSuccess:(BalancedTokenizeResponseBlock)successBlock
                     onError:(BalancedErrorBlock)errorBlock;
- (void)createCardWithNumber:(NSString *)number
             expirationMonth:(NSUInteger)expMonth
              expirationYear:(NSUInteger)expYear
                   onSuccess:(BalancedTokenizeResponseBlock)successBlock
                     onError:(BalancedErrorBlock)errorBlock
              optionalFields:(NSDictionary *)optionalFields;
- (void)createBankAccountWithRoutingNumber:(NSString *)routingNumber
                             accountNumber:(NSString *)accountNumber
                               accountType:(BPBankAccountType)accountType
                                      name:(NSString *)name
                                 onSuccess:(BalancedTokenizeResponseBlock)successBlock
                                   onError:(BalancedErrorBlock)errorBlock;
- (void)createBankAccountWithRoutingNumber:(NSString *)routingNumber
                             accountNumber:(NSString *)accountNumber
                               accountType:(BPBankAccountType)accountType
                                      name:(NSString *)name
                                 onSuccess:(BalancedTokenizeResponseBlock)successBlock
                                   onError:(BalancedErrorBlock)errorBlock
                            optionalFields:(NSDictionary *)optionalFields;
@end
