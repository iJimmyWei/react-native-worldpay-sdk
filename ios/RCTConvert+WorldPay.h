//
//  RCTConvert+WorldPay.h
//  RNWorldPay
//
//  Created by Simon Mitchell on 16/05/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

@import PassKit;
#import <React/RCTConvert.h>
#import "Worldpay.h"

@interface RCTConvert (WorldPay)

+ (WorldpayValidationType)WorldpayValidationType:(id)json;

+ (PKAddressField)PKAddressField:(id)json;

+ (PKMerchantCapability)PKMerchantCapability:(id)json;

+ (PKShippingType)PKShippingType:(id)json;

+ (PKPaymentSummaryItemType)PKPaymentSummaryItemType:(id)json;

+ (PKPaymentNetwork)PKPaymentNetwork:(id)json;

+ (PKPaymentSummaryItem *)PKPaymentSummaryItem:(id)json;

+ (PKShippingMethod *)PKShippingMethod:(id)json;

+ (PKContact *)PKContact:(id)json;

@end
