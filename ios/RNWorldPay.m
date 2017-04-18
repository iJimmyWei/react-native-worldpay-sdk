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

RCT_EXPORT_METHOD(createToken:(id)cardInfo resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    
    [[Worldpay sharedInstance] createTokenWithNameOnCard:cardInfo[@"name"] cardNumber:cardInfo[@"number"] expirationMonth:cardInfo[@"expiryMonth"] expirationYear:cardInfo[@"expiryYear"] CVC:cardInfo[@"cvc"] success:^(int code, NSDictionary *responseDictionary) {
        resolve(@{@"code":@(code), @"response": responseDictionary});
    } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
        reject(@"CREATE_TOKEN_FAILED", errors.firstObject ? ((NSError *)errors.firstObject).localizedDescription : @"Unknown Error", errors.firstObject);
    }];
}

RCT_EXPORT_METHOD(reuseToken:(NSString *)token cvc:(NSString *)cvc resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject){
    
    [[Worldpay sharedInstance] reuseToken:token withCVC:cvc success:^(int code, NSDictionary *responseDictionary) {
        resolve(@{@"code":@(code), @"response": responseDictionary});
    } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
        reject(@"REUSE_TOKEN_FAILED", errors.firstObject ? ((NSError *)errors.firstObject).localizedDescription : @"Unknown Error", errors.firstObject);
    }];
}

RCT_EXPORT_METHOD(validateCardDetails:(id)cardInfo resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSArray<NSError *> *errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:cardInfo[@"name"] cardNumber:cardInfo[@"number"] expirationMonth:cardInfo[@"expiryMonth"] expirationYear:cardInfo[@"expiryYear"] CVC:cardInfo[@"cvc"]];
    resolve(@{@"errors": errors});
}

RCT_EXPORT_METHOD(validateCVC:(NSString *)cvc cardToken:(NSString *)cardToken resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    NSArray<NSError *> *errors = [[Worldpay sharedInstance] validateCardDetailsWithCVC:cvc token:cardToken];
    resolve(@{@"errors": errors});
}

@end
  
