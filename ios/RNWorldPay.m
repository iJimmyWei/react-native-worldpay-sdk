#import "RNWorldPay.h"
#import "Worldpay.h"
#import <React/RCTConvert.h>

@implementation RCTConvert (WorldPay)
RCT_ENUM_CONVERTER(WorldpayValidationType, (@{ @"advanced" : @(WorldpayValidationTypeAdvanced),
                                               @"basic" : @(WorldpayValidationTypeBasic)
                                            }),WorldpayValidationTypeBasic, intValue);
@end


@implementation RNWorldPay

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(configure:(id)config) {
    
    [[Worldpay sharedInstance] setClientKey:config[@"clientKey"]];
    
    if (config[@"reusable"] && [config[@"reusable"] isKindOfClass:[NSNumber class]]) {
        [[Worldpay sharedInstance] setReusable:[RCTConvert BOOL:config[@"reusable"]]];
    }
    
    if (config[@"validation"] && [config[@"validation"] isKindOfClass:[NSString class]]) {
        [[Worldpay sharedInstance] setValidationType:[RCTConvert WorldpayValidationType:config[@"validation"]]];
    }
}

- (NSError *)errorFromResponse:(NSDictionary *)response withError:(NSError *)error fallbackCode:(NSString *)fallbackCode
{
    NSMutableDictionary *errorInfo = [NSMutableDictionary new];
    
    if (response[@"message"]) {
        errorInfo[@"message"] = response[@"message"];
    }
    
    if (response[@"description"]) {
        errorInfo[NSLocalizedDescriptionKey] = response[@"description"];
    }
    
    return [NSError errorWithDomain:@"RNWorldPayErrorDomain" code:error.code
                           userInfo:errorInfo];
}

RCT_EXPORT_METHOD(createToken:(id)cardInfo resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[Worldpay sharedInstance] createTokenWithNameOnCard:cardInfo[@"name"] cardNumber:cardInfo[@"number"] expirationMonth:cardInfo[@"expiryMonth"] expirationYear:cardInfo[@"expiryYear"] CVC:cardInfo[@"cvc"] success:^(int code, NSDictionary *responseDictionary) {
        
        resolve(@{@"code":@(code), @"response": responseDictionary ? : [NSNull new]});
        
    } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
        
        reject(responseDictionary[@"customCode"] ? : @"CREATE_TOKEN_FAILED",
               responseDictionary[@"description"] ? : @"Unknown Error",
               [self errorFromResponse:responseDictionary withError:errors.firstObject fallbackCode:@"CREATE_TOKEN_FAILED"]);
    }];
}

RCT_EXPORT_METHOD(reuseToken:(id)tokenInfo resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject){
    
    [[Worldpay sharedInstance] reuseToken:tokenInfo[@"token"] withCVC:tokenInfo[@"cvc"] success:^(int code, NSDictionary *responseDictionary) {
        
        resolve(@{@"code":@(code), @"response": responseDictionary ? : [NSNull new]});
        
    } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
        
        reject(responseDictionary[@"customCode"] ? : @"REUSE_TOKEN_FAILED",
               responseDictionary[@"description"] ? : @"Unknown Error",
               [self errorFromResponse:responseDictionary withError:errors.firstObject fallbackCode:@"REUSE_TOKEN_FAILED"]);
    }];
}

RCT_EXPORT_METHOD(validateCardDetails:(id)cardInfo resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSArray<NSError *> *errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:cardInfo[@"name"] cardNumber:cardInfo[@"number"] expirationMonth:cardInfo[@"expiryMonth"] expirationYear:cardInfo[@"expiryYear"] CVC:cardInfo[@"cvc"]];
    
    NSMutableDictionary *returnStatuses = [@{
        @"name": @(true),
        @"number": @(true),
        @"expiry": @(true),
        @"cvc": @(true)
    } mutableCopy];
    
    [errors enumerateObjectsUsingBlock:^(NSError * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        switch (obj.code) {
            case 1:
                returnStatuses[@"expiry"] = @(false);
                break;
            case 2:
                returnStatuses[@"number"] = @(false);
                break;
            case 3:
                returnStatuses[@"name"] = @(false);
                break;
            case 4:
                returnStatuses[@"cvc"] = @(false);
                break;
            default:
                break;
        }
    }];
    
    resolve(returnStatuses);
}

RCT_EXPORT_METHOD(validateToken:(id)tokenInfo resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSArray<NSError *> *errors = [[Worldpay sharedInstance] validateCardDetailsWithCVC:tokenInfo[@"cvc"] token:tokenInfo[@"token"]];
    NSMutableDictionary *returnStatuses = [@{
                                             @"token": @(true),
                                             @"cvc": @(true)
                                             } mutableCopy];
    
    [errors enumerateObjectsUsingBlock:^(NSError * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        switch (obj.code) {
            case 400:
                returnStatuses[@"token"] = @(false);
                break;
            case 4:
                returnStatuses[@"cvc"] = @(false);
                break;
            default:
                break;
        }
    }];
    
    resolve(returnStatuses);
}

@end
  
