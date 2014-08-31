//
//  BPBankAccount.h
//  Balanced iOS
//
//  Created by Ben Mills on 3/9/13.
//

#import <Foundation/Foundation.h>

@interface BPBankAccount : NSObject

typedef NS_ENUM(NSUInteger, BPBankAccountType)
{
    BPBankAccountTypeUnknown,
    BPBankAccountTypeChecking,
    BPBankAccountTypeSavings
};

- (id)initWithRoutingNumber:(NSString *)routingNumber accountNumber:(NSString *)accountNumber accountType:(BPBankAccountType)accountType name:(NSString *)name;
- (id)initWithRoutingNumber:(NSString *)routingNumber accountNumber:(NSString *)accountNumber accountType:(BPBankAccountType)accountType name:(NSString *)name optionalFields:(NSDictionary *)optionalFields;

@property (nonatomic, assign, readonly, getter=getRoutingNumberValid) BOOL routingNumberValid;
@property (nonatomic, assign, readonly, getter=getAccountTypeValid) BOOL accountTypeValid;
@property (nonatomic, assign, readonly, getter=getNameValid) BOOL nameValid;
@property (nonatomic, assign, readonly, getter=getValid) BOOL valid;
@property (nonatomic, assign) BPBankAccountType accountType;
@property (nonatomic, strong) NSString *routingNumber;
@property (nonatomic, strong) NSString *accountNumber;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSMutableArray *errors;
@property (nonatomic, strong) NSDictionary *optionalFields;

@end
