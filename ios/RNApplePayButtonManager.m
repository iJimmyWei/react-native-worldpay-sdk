//
//  RNApplePayButtonManager.m
//  RNWorldPay
//
//  Created by Simon Mitchell on 15/05/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

@import PassKit;
#import "RNApplePayButtonManager.h"
#import "RNPaymentButton.h"
#import "RNShadowPaymentButton.h"


@interface RCTConvert (ApplePay)

+ (PKPaymentButtonStyle)PKPaymentButtonStyle:(id)json;

+ (PKPaymentButtonType)PKPaymentButtonType:(id)json;

@end

@implementation RCTConvert (ApplePay)

RCT_ENUM_CONVERTER(PKPaymentButtonStyle, (@{
                                            @"black": @(PKPaymentButtonStyleBlack),
                                            @"white": @(PKPaymentButtonStyleWhite),
                                            @"whiteOutline": @(PKPaymentButtonStyleWhiteOutline),
                                            }), PKPaymentButtonStyleBlack, integerValue)


+ (PKPaymentButtonType)PKPaymentButtonType:(id)json
{
    static NSDictionary *mapping;
    static dispatch_once_t onceToken;
    
    NSMutableDictionary *allowedTypes = [NSMutableDictionary dictionaryWithDictionary:@{
        @"plain": @(PKPaymentButtonTypePlain),
        @"buy": @(PKPaymentButtonTypeBuy),
    }];
    
    NSOperatingSystemVersion ios9_0_0 = (NSOperatingSystemVersion){9, 0, 0};
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios9_0_0]) {
        allowedTypes[@"setup"] = @(PKPaymentButtonTypeSetUp);
    }
    
    NSOperatingSystemVersion ios10_0_0 = (NSOperatingSystemVersion){10, 0, 0};
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios10_0_0]) {
        allowedTypes[@"inStore"] = @(PKPaymentButtonTypeInStore);
    }
    
    NSOperatingSystemVersion ios10_3_0 = (NSOperatingSystemVersion){10, 3, 0};
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios10_3_0]) {
        allowedTypes[@"donate"] = @(PKPaymentButtonTypeDonate);
    }
    
    dispatch_once(&onceToken, ^{
        mapping = allowedTypes;
    });
    
    return [RCTConvertEnumValue("PKPaymentButtonType", mapping, @(PKPaymentButtonTypePlain), json) integerValue];
}

@end

@implementation RNApplePayButtonManager

RCT_EXPORT_VIEW_PROPERTY(enabled, BOOL)

RCT_EXPORT_SHADOW_PROPERTY(onPress, RCTBubblingEventBlock)

RCT_CUSTOM_SHADOW_PROPERTY(buttonStyle, PKPaymentButtonStyle, RNShadowPaymentButton)
{
    view.style = [RCTConvert PKPaymentButtonStyle:json];
}

RCT_CUSTOM_SHADOW_PROPERTY(type, PKPaymentButtonType, RNShadowPaymentButton) {
    view.type = [RCTConvert PKPaymentButtonType:json];
}

RCT_EXPORT_MODULE()

- (UIView *)view
{
    RNPaymentButton *button = [[RNPaymentButton alloc] init];
    return button;
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

- (RCTShadowView *)shadowView
{
    return [RNShadowPaymentButton new];
}

@end
