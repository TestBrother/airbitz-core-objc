//
//  ABCError.m
//  Airbitz
//

#import <Foundation/Foundation.h>
#import "ABCContext+Internal.h"

@interface ABCError ()

@end

@implementation ABCError

+ (ABCError *)makeNSError:(tABC_Error)error;
{
    return [ABCError makeNSError:error description:[ABCError errorMap:error]];
}

+ (ABCError *)makeNSError:(tABC_Error)error description:(NSString *)description;
{
    if (ABCConditionCodeOk == error.code)
    {
        return nil;
    }
    else
    {
        NSString *failureReason = @"";
        NSString *failureDetail = @"";
        if (ABCConditionCodeNULLPtr != error.code)
        {
            failureReason = [NSString stringWithUTF8String:error.szDescription];
            failureDetail = [NSString stringWithFormat:@"%@: %@:%d",
                             [NSString stringWithUTF8String:error.szSourceFunc],
                             [NSString stringWithUTF8String:error.szSourceFile],
                             error.nSourceLine];
        }
        
        if (!description)
            description = @"";
        if (!failureReason)
            failureReason = @"";
        if (!failureDetail)
            failureDetail = @"";
        
        ABCError *abcError = [ABCError errorWithDomain:ABCErrorDomain
                                                  code:error.code
                                              userInfo:@{ NSLocalizedDescriptionKey:description,
                                                          NSLocalizedFailureReasonErrorKey:failureReason,
                                                          NSLocalizedRecoverySuggestionErrorKey:failureDetail }];
        return abcError;
    }
}

+(ABCError *) errorWithDomain:(NSInteger) code
                     userInfo:(NSDictionary *)userInfo;
{
    ABCError *error = [ABCError alloc];
    error.code = code;
    error.userInfo = userInfo;
    
    return error;
}


+ (NSString *)errorMap:(tABC_Error)error;
{
    if (ABCConditionCodeInvalidPinWait == error.code)
    {
        NSString *description = [NSString stringWithUTF8String:error.szDescription];
        if ([@"0" isEqualToString:description]) {
            return NSLocalizedString(@"Invalid PIN/Password", nil);
        } else {
            return [NSString stringWithFormat:
                    NSLocalizedString(@"Too many failed login attempts. Please try again in %@ seconds.", nil),
                    description];
        }
    }
    else
    {
        return [ABCError conditionCodeMap:(ABCConditionCode) error.code];
    }

}

+ (NSString *)conditionCodeMap:(ABCConditionCode) cc;
{
    NSString *str;

    switch (cc)
    {
        case ABCConditionCodeAccountAlreadyExists:
            return NSLocalizedString(@"This account already exists.", nil);
        case ABCConditionCodeAccountDoesNotExist:
            return NSLocalizedString(@"We were unable to find your account. Be sure your username is correct.", nil);
        case ABCConditionCodeBadPassword:
            return NSLocalizedString(@"Invalid username, PIN, or password", nil);
        case ABCConditionCodeWalletAlreadyExists:
            return NSLocalizedString(@"Wallet already exists.", nil);
        case ABCConditionCodeInvalidWalletID:
            return NSLocalizedString(@"Wallet does not exist.", nil);
        case ABCConditionCodeURLError:
        case ABCConditionCodeServerError:
            return NSLocalizedString(@"Unable to connect to Airbitz server. Please try again later.", nil);
        case ABCConditionCodeNoRecoveryQuestions:
            return NSLocalizedString(@"No recovery questions are available for this user", nil);
        case ABCConditionCodeNotSupported:
            return NSLocalizedString(@"This operation is not supported.", nil);
        case ABCConditionCodeInsufficientFunds:
            return NSLocalizedString(@"Insufficient funds", nil);
        case ABCConditionCodeSpendDust:
            return NSLocalizedString(@"Amount is too small", nil);
        case ABCConditionCodeSynchronizing:
            return NSLocalizedString(@"Synchronizing with the network.", nil);
        case ABCConditionCodeNonNumericPin:
            return NSLocalizedString(@"PIN must be a numeric value.", nil);
        case ABCConditionCodeNULLPtr:
            return NSLocalizedString(@"Invalid NULL Ptr passed to ABC", nil);
        case ABCConditionCodeNoAvailAccountSpace:
            return NSLocalizedString(@"No Available Account Space", nil);
        case ABCConditionCodeDirReadError:
            return NSLocalizedString(@"Directory Read Error", nil);
        case ABCConditionCodeFileOpenError:
            return NSLocalizedString(@"File Open Error", nil);
        case ABCConditionCodeFileReadError:
            return NSLocalizedString(@"File Read Error", nil);
        case ABCConditionCodeFileWriteError:
            return NSLocalizedString(@"File Write Error", nil);
        case ABCConditionCodeFileDoesNotExist:
            return NSLocalizedString(@"File Does Not Exist Error", nil);
        case ABCConditionCodeUnknownCryptoType:
        case ABCConditionCodeInvalidCryptoType:
        case ABCConditionCodeDecryptError:
        case ABCConditionCodeDecryptFailure:
        case ABCConditionCodeEncryptError:
        case ABCConditionCodeScryptError:
            return NSLocalizedString(@"Encryption/Decryption Error", nil);
        case ABCConditionCodeMutexError:
            return NSLocalizedString(@"Mutex Error", nil);
        case ABCConditionCodeJSONError:
            return NSLocalizedString(@"JSON Error", nil);
        case ABCConditionCodeNoTransaction:
            return NSLocalizedString(@"No Transactions in Wallet", nil);
        case ABCConditionCodeSysError:
            return NSLocalizedString(@"Trouble accessing network. Please check network connection", nil);
        case ABCConditionCodeNotInitialized:
        case ABCConditionCodeReinitialization:
        case ABCConditionCodeParseError:
        case ABCConditionCodeNoRequest:
        case ABCConditionCodeNoAvailableAddress:
        case ABCConditionCodeError:
        default:
            str = [NSString stringWithFormat:@"%@ %d", NSLocalizedString(@"An error has occurred:", nil), cc];
            return str;
    }
}


@end
