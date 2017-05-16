#import "RNWorldPay.h"
#import "Worldpay.h"
#import "Worldpay+ApplePay.h"
#import "RCTConvert+WorldPay.h"
#import "UIWindow+VisibleViewController.h"
#import "PKPayment+Serialisation.h"
#import "RCTUtils.h"
@import PassKit;

@interface RNWorldPay () <PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic, copy) void (^applePayPaymentCompletion)(PKPaymentAuthorizationStatus);

@property (nonatomic, copy) RCTPromiseResolveBlock applePayResolveBlock;

@property (nonatomic, copy) RCTPromiseRejectBlock applePayRejectBlock;

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

#pragma mark-
#pragma mark Apple Pay

RCT_REMAP_METHOD(canMakeApplePayPayments, canMakeApplePayPamentsWithResolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    if ([PKPaymentAuthorizationViewController canMakePayments]) {
        resolve(@{@"available": @(true)});
    } else {
        resolve(@{@"available": @(false)});
    }
}

RCT_EXPORT_METHOD(canMakeApplePayPaymentsUsingNetworks:(id)networks resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSArray <PKPaymentNetwork> *paymentNetworks = [NSArray new];
    
    if ([networks isKindOfClass:[NSArray class]]) {
        paymentNetworks = networks;
    }
    
    if ([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:paymentNetworks]) {
        resolve(@{@"setup":@(true)});
    } else {
        resolve(@{@"setup":@(false)});
    }
}

RCT_EXPORT_METHOD(createTokenWithApplePaymentData:(NSString *)base64Data resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64Data options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    if (!data) {
        reject(@"com.rnworldpay.error", @"Couldn't base64 decode apple pay payment data", [NSError errorWithDomain:@"com.rnworldpay.error" code:400 userInfo:nil]);
        return;
    }
    
    [[Worldpay sharedInstance] createTokenWithPaymentData:data success:^(int code, NSDictionary *responseDictionary) {
        
        resolve(@{@"code":@(code), @"response": responseDictionary ? : [NSNull new]});
        
    } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
        
        reject(responseDictionary[@"customCode"] ? : @"CREATE_TOKEN_FAILED",
               responseDictionary[@"description"] ? : @"Unknown Error",
               [self errorFromResponse:responseDictionary withError:errors.firstObject fallbackCode:@"CREATE_TOKEN_FAILED"]);
    }];
}

RCT_EXPORT_METHOD(presentSetupApplePay) {
    [[PKPassLibrary new] openPaymentSetup];
}

RCT_EXPORT_METHOD(requestApplePayPayment:(NSString *)merchantId config:(id)config resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    if (self.applePayRejectBlock || self.applePayResolveBlock || self.applePayPaymentCompletion) {
        reject(@"com.rnworldpay.error", @"Cannot run multiple payment requests at the same time!", [NSError errorWithDomain:@"com.rnworldpay.error" code:429 userInfo:nil]);
        return;
    }
    
    // Create the payment request
    PKPaymentRequest *request = [[Worldpay sharedInstance] createPaymentRequestWithMerchantIdentifier:merchantId];
    
    // Payment Information
    if (config[@"countryCode"]) {
        request.countryCode = [RCTConvert NSString:config[@"countryCode"]];
    }
    
    if (config[@"currencyCode"]) {
        request.currencyCode = [RCTConvert NSString:config[@"currencyCode"]];
    }
    
    if (config[@"applicationData"]) {
        request.applicationData = [RCTConvert NSData:config[@"applicationData"]];
    }
    
    if (config[@"supportedNetworks"] && [config[@"supportedNetworks"] isKindOfClass:[NSArray class]]) {
        
        NSMutableArray *supportedNetworks = [NSMutableArray new];
        
        [((NSArray *)config[@"supportedNetworks"]) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            PKPaymentNetwork network = [RCTConvert PKPaymentNetwork:obj];
            if (network) {
                [supportedNetworks addObject:network];
            }
        }];
        
        request.supportedNetworks = supportedNetworks;
    }
    
    if (config[@"merchantCapabilities"]) {
        request.merchantCapabilities = [RCTConvert PKMerchantCapability:config[@"merchantCapabilities"]];
    }
    
    if (config[@"paymentSummaryItems"] && [config[@"paymentSummaryItems"] isKindOfClass:[NSArray class]]) {
        
        NSMutableArray *summaryItems = [NSMutableArray new];
        
        [((NSArray *)config[@"paymentSummaryItems"]) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            PKPaymentSummaryItem *paymentSummaryItem = [RCTConvert PKPaymentSummaryItem:obj];
            if (paymentSummaryItem) {
                [summaryItems addObject:paymentSummaryItem];
            }
        }];
        
        request.paymentSummaryItems = summaryItems;
    }
    
    // Billing and Shipping information
    
    if (config[@"requiredBillingAddressFields"]) {
        request.requiredBillingAddressFields = [RCTConvert PKAddressField:config[@"requiredBillingAddressFields"]];
    }
    
    if (config[@"requiredShippingAddressFields"]) {
        request.requiredShippingAddressFields = [RCTConvert PKAddressField:config[@"requiredShippingAddressFields"]];
    }
    
    if (config[@"shippingMethods"] && [config[@"shippingMethods"] isKindOfClass:[NSArray class]]) {
        
        NSMutableArray *shippingMethods = [NSMutableArray new];
        
        [((NSArray *)config[@"shippingMethods"]) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            PKShippingMethod *shippingMethod = [RCTConvert PKShippingMethod:obj];
            if (shippingMethod) {
                [shippingMethods addObject:shippingMethod];
            }
        }];
        request.shippingMethods = shippingMethods;
    }
    
    if (config[@"shippingType"]) {
        request.shippingType = [RCTConvert PKShippingType:config[@"shippingType"]];
    }
    
    if (config[@"billingContact"]) {
        request.billingContact = [RCTConvert PKContact:config[@"billingContact"]];
    }
    
    if (config[@"shippingContact"]) {
        request.shippingContact = [RCTConvert PKContact:config[@"shippingContact"]];
    }
    
    PKPaymentAuthorizationViewController *authorizationViewController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    authorizationViewController.delegate = self;
    
    if (!authorizationViewController) {
        reject(@"com.rnworldpay.error", @"Failed to create PKPaymentAuthorizationViewController", [NSError errorWithDomain:@"com.rnworldpay.error" code:400 userInfo:nil]);
        return;
    }
    
    self.applePayResolveBlock = resolve;
    self.applePayRejectBlock = reject;
    
    UIViewController *controller = RCTKeyWindow().visibleViewController;
    [controller presentViewController:authorizationViewController animated:true completion:nil];
}

#pragma mark-
#pragma mark WorldPay

RCT_EXPORT_METHOD(createToken:(id)cardInfo resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSString *expiryMonth = cardInfo[@"expiryMonth"];
    if (expiryMonth && [expiryMonth isKindOfClass:[NSNumber class]]) {
        expiryMonth = [NSString stringWithFormat:@"%li", (long)[(NSNumber *)expiryMonth integerValue]];
    }
    
    NSString *expiryYear = cardInfo[@"expiryYear"];
    if (expiryYear && [expiryYear isKindOfClass:[NSNumber class]]) {
        expiryYear = [NSString stringWithFormat:@"%li", (long)[(NSNumber *)expiryYear integerValue]];
    }
    
    NSString *cardNumber = cardInfo[@"number"];
    if (cardNumber && [cardNumber isKindOfClass:[NSNumber class]]) {
        cardNumber = [NSString stringWithFormat:@"%li", (long)[(NSNumber *)cardNumber integerValue]];
    }
    
    NSString *cvc = cardInfo[@"cvc"];
    if (cvc && [cvc isKindOfClass:[NSNumber class]]) {
        cvc = [NSString stringWithFormat:@"%li", (long)[(NSNumber *)cvc integerValue]];
    }
    
    [[Worldpay sharedInstance] createTokenWithNameOnCard:cardInfo[@"name"] cardNumber:cardNumber expirationMonth:expiryMonth expirationYear:expiryYear CVC:cvc success:^(int code, NSDictionary *responseDictionary) {
        
        resolve(@{@"code":@(code), @"response": responseDictionary ? : [NSNull new]});
        
    } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
        
        reject(responseDictionary[@"customCode"] ? : @"CREATE_TOKEN_FAILED",
               responseDictionary[@"description"] ? : @"Unknown Error",
               [self errorFromResponse:responseDictionary withError:errors.firstObject fallbackCode:@"CREATE_TOKEN_FAILED"]);
    }];
}

RCT_EXPORT_METHOD(reuseToken:(id)tokenInfo resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject){
    
    NSString *cvc = tokenInfo[@"cvc"];
    if (cvc && [cvc isKindOfClass:[NSNumber class]]) {
        cvc = [NSString stringWithFormat:@"%li", (long)[(NSNumber *)cvc integerValue]];
    }
    
    [[Worldpay sharedInstance] reuseToken:tokenInfo[@"token"] withCVC:cvc success:^(int code, NSDictionary *responseDictionary) {
        
        resolve(@{@"code":@(code), @"response": responseDictionary ? : [NSNull new]});
        
    } failure:^(NSDictionary *responseDictionary, NSArray *errors) {
        
        reject(responseDictionary[@"customCode"] ? : @"REUSE_TOKEN_FAILED",
               responseDictionary[@"description"] ? : @"Unknown Error",
               [self errorFromResponse:responseDictionary withError:errors.firstObject fallbackCode:@"REUSE_TOKEN_FAILED"]);
    }];
}

RCT_EXPORT_METHOD(validateCardDetails:(id)cardInfo resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    
    NSString *expiryMonth = cardInfo[@"expiryMonth"];
    if (expiryMonth && [expiryMonth isKindOfClass:[NSNumber class]]) {
        expiryMonth = [NSString stringWithFormat:@"%li", (long)[(NSNumber *)expiryMonth integerValue]];
    }
    
    NSString *expiryYear = cardInfo[@"expiryYear"];
    if (expiryYear && [expiryYear isKindOfClass:[NSNumber class]]) {
        expiryYear = [NSString stringWithFormat:@"%li", (long)[(NSNumber *)expiryYear integerValue]];
    }
    
    NSString *cardNumber = cardInfo[@"number"];
    if (cardNumber && [cardNumber isKindOfClass:[NSNumber class]]) {
        cardNumber = [NSString stringWithFormat:@"%li", (long)[(NSNumber *)cardNumber integerValue]];
    }
    
    NSString *cvc = cardInfo[@"cvc"];
    if (cvc && [cvc isKindOfClass:[NSNumber class]]) {
        cvc = [NSString stringWithFormat:@"%li", (long)[(NSNumber *)cvc integerValue]];
    }
    
    NSArray<NSError *> *errors = [[Worldpay sharedInstance] validateCardDetailsWithHolderName:cardInfo[@"name"] cardNumber:cardNumber expirationMonth:expiryMonth expirationYear:expiryYear CVC:cvc];
    
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
    
    NSString *cvc = tokenInfo[@"cvc"];
    if (cvc && [cvc isKindOfClass:[NSNumber class]]) {
        cvc = [NSString stringWithFormat:@"%li", (long)[(NSNumber *)cvc integerValue]];
    }
    
    NSArray<NSError *> *errors = [[Worldpay sharedInstance] validateCardDetailsWithCVC:cvc token:tokenInfo[@"token"]];
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

#pragma mark export constants

- (NSDictionary<NSString *,id> *)constantsToExport
{
    
    NSMutableDictionary *networks = [NSMutableDictionary dictionaryWithDictionary:@{
                                     @"amex": PKPaymentNetworkAmex,
                                     @"masterCard":PKPaymentNetworkMasterCard,
                                     @"visa": PKPaymentNetworkVisa}];
    
    if (&PKPaymentNetworkCarteBancaire != NULL) {
        networks[@"carteBancaire"] = PKPaymentNetworkCarteBancaire;
    }
    
    if (&PKPaymentNetworkChinaUnionPay != NULL) {
        networks[@"chinaUnionPay"] = PKPaymentNetworkChinaUnionPay;
    }
    
    if (&PKPaymentNetworkDiscover != NULL) {
        networks[@"discover"] = PKPaymentNetworkDiscover;
    }
    
    if (&PKPaymentNetworkInterac != NULL) {
        networks[@"interac"] = PKPaymentNetworkInterac;
    }
    
    if (&PKPaymentNetworkPrivateLabel != NULL) {
        networks[@"privateLabel"] = PKPaymentNetworkPrivateLabel;
    }
    
    if (&PKPaymentNetworkJCB != NULL) {
        networks[@"jcb"] = PKPaymentNetworkJCB;
    }
    
    if (&PKPaymentNetworkSuica != NULL) {
        networks[@"suica"] = PKPaymentNetworkSuica;
    }
    
    if (&PKPaymentNetworkQuicPay != NULL) {
        networks[@"quicPay"] = PKPaymentNetworkQuicPay;
    }
    
    if (&PKPaymentNetworkIDCredit != NULL) {
        networks[@"idCredit"] = PKPaymentNetworkIDCredit;
    }
    
    return @{
        @"paymentNetworks": networks
    };
}

#pragma mark-
#pragma mark PKPaymentAuthorizationViewControllerDelegate

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    // If we still have applePayPaymentCompletion it means that the completion block hasn't been called to the user cancelled the payment, in which case call reject block
    if (self.applePayPaymentCompletion && self.applePayRejectBlock) {
        self.applePayRejectBlock(@"com.rnworldpay.error", @"Apple pay flow was cancelled", [NSError errorWithDomain:@"com.rnworldpay.error" code:001 userInfo:nil]);
    }
    
    self.applePayRejectBlock = nil;
    self.applePayResolveBlock = nil;
    self.applePayPaymentCompletion = nil;
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    if (self.applePayResolveBlock) {
        self.applePayResolveBlock([payment dictionaryRepresentation]);
    }
    self.applePayResolveBlock = nil;
    self.applePayPaymentCompletion = completion;
}

@end
  
