//
//  RCTConvert+WorldPay.m
//  RNWorldPay
//
//  Created by Simon Mitchell on 16/05/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RCTConvert+WorldPay.h"

@implementation RCTConvert (WorldPay)

RCT_ENUM_CONVERTER(WorldpayValidationType, (@{
                                              @"advanced" : @(WorldpayValidationTypeAdvanced),
                                              @"basic" : @(WorldpayValidationTypeBasic)
                                              }),WorldpayValidationTypeBasic, intValue);

RCT_MULTI_ENUM_CONVERTER(PKAddressField, (@{
                                            @"none": @(PKAddressFieldNone),
                                            @"postalAddress": @(PKAddressFieldPostalAddress),
                                            @"phone": @(PKAddressFieldPhone),
                                            @"email": @(PKAddressFieldEmail),
                                            @"name": @(PKAddressFieldName),
                                            @"all": @(PKAddressFieldAll)
                                            }), PKAddressFieldPostalAddress, unsignedLongLongValue);

RCT_MULTI_ENUM_CONVERTER(PKMerchantCapability, (@{
                                                  @"3DS": @(PKMerchantCapability3DS),
                                                  @"credit": @(PKMerchantCapabilityCredit),
                                                  @"EMV": @(PKMerchantCapabilityEMV),
                                                  @"debit": @(PKMerchantCapabilityDebit)
                                                  }), PKMerchantCapability3DS, unsignedLongLongValue);

RCT_ENUM_CONVERTER(PKShippingType, (@{
                                      @"shipping": @(PKShippingTypeShipping),
                                      @"delivery": @(PKShippingTypeDelivery),
                                      @"storePickup": @(PKShippingTypeStorePickup),
                                      @"servicePickup": @(PKShippingTypeServicePickup)
                                      }), PKShippingTypeShipping, intValue);

RCT_ENUM_CONVERTER(PKPaymentSummaryItemType, (@{
                                                @"final": @(PKPaymentSummaryItemTypeFinal),
                                                @"pending": @(PKPaymentSummaryItemTypePending),
                                                }), PKPaymentSummaryItemTypeFinal, intValue);

RCT_CUSTOM_CONVERTER(PKPaymentNetwork, PKPaymentNetwork, [RCTConvert convertPaymentNetwork: json])

+ (PKPaymentNetwork)convertPaymentNetwork:(id)json
{
    if ([json isKindOfClass:[NSString class]]) {
        
        if ([json isEqualToString:@"amex"]) {
            return PKPaymentNetworkAmex;
        }
        
        if ([json isEqualToString:@"masterCard"]) {
            return PKPaymentNetworkMasterCard;
        }
        
        if ([json isEqualToString:@"visa"]) {
            return PKPaymentNetworkVisa;
        }
        
        if ([json isEqualToString:@"carteBancaire"] && &PKPaymentNetworkCarteBancaire != NULL) {
            return PKPaymentNetworkCarteBancaire;
        }
        
        if ([json isEqualToString:@"chinaUnionPay"] && &PKPaymentNetworkChinaUnionPay != NULL) {
            return PKPaymentNetworkChinaUnionPay;
        }
        
        if ([json isEqualToString:@"discover"] && &PKPaymentNetworkDiscover != NULL) {
            return PKPaymentNetworkDiscover;
        }
        
        if ([json isEqualToString:@"interac"] && &PKPaymentNetworkInterac != NULL) {
            return PKPaymentNetworkInterac;
        }
        
        if ([json isEqualToString:@"privateLabel"] && &PKPaymentNetworkPrivateLabel != NULL) {
            return PKPaymentNetworkPrivateLabel;
        }
        
        if ([json isEqualToString:@"jcb"] && &PKPaymentNetworkJCB != NULL) {
            return PKPaymentNetworkJCB;
        }
        
        if ([json isEqualToString:@"suica"] && &PKPaymentNetworkSuica != NULL) {
            return PKPaymentNetworkSuica;
        }
        
        if ([json isEqualToString:@"quicPay"] && &PKPaymentNetworkQuicPay != NULL) {
            return PKPaymentNetworkQuicPay;
        }
        
        if ([json isEqualToString:@"idCredit"] && &PKPaymentNetworkIDCredit != NULL) {
            return PKPaymentNetworkIDCredit;
        }
        
        return nil;
        
    } else {
        return nil;
    }
}

RCT_CUSTOM_CONVERTER(PKPaymentSummaryItem *, PKPaymentSummaryItem, [RCTConvert convertPaymentSummaryItem:json]);

+ (PKPaymentSummaryItem *)convertPaymentSummaryItem:(id)json
{
    if (![json isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if (!json[@"label"] || ![json[@"label"] isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    if (!json[@"amount"] || ![json[@"amount"] isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    
    NSString *label = json[@"label"];
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[json[@"amount"] decimalValue]];
    
    if (json[@"type"]) {
        
        PKPaymentSummaryItemType type = [RCTConvert PKPaymentSummaryItemType:json[@"type"]];
        return [PKPaymentSummaryItem summaryItemWithLabel:label amount:amount type:type];
        
    } else {
        
        return [PKPaymentSummaryItem summaryItemWithLabel:label amount:amount];
    }
}

RCT_CUSTOM_CONVERTER(PKShippingMethod *, PKShippingMethod, [RCTConvert convertShippingMethod:json]);

+ (PKShippingMethod *)convertShippingMethod:(id)json
{
    if (![json isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if (!json[@"identifier"]) {
        return nil;
    }
    
    if (!json[@"description"] || ![json[@"description"] isKindOfClass:[NSString class]]) {
        return nil;
    }

    if (!json[@"amount"] || ![json[@"amount"] isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    
    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithDecimal:[json[@"amount"] decimalValue]];
    
    PKShippingMethod *shippingMethod;

    if (json[@"type"]) {
        
        PKPaymentSummaryItemType type = [RCTConvert PKPaymentSummaryItemType:json[@"type"]];
        shippingMethod = [PKShippingMethod summaryItemWithLabel:json[@"description"] amount:amount type:type];
        
    } else {
        
        shippingMethod = [PKShippingMethod summaryItemWithLabel:json[@"description"] amount:amount];
    }
    
    
    shippingMethod.identifier = [RCTConvert NSString:json[@"identifier"]];
    return shippingMethod;
}

RCT_CUSTOM_CONVERTER(PKContact *, PKContact, [RCTConvert convertContact:json]);

+ (PKContact *)convertContact:(id)json
{
    if (![json isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    PKContact *contact = [PKContact new];
    
    if (json[@"emailAddress"] && [json[@"emailAddress"] isKindOfClass:[NSString class]]) {
        contact.emailAddress = json[@"emailAddress"];
    }
    
    
    NSDictionary *name = json[@"name"];
    
    if (name && [name isKindOfClass:[NSDictionary class]]) {
        
        NSPersonNameComponents *nameComponents = [NSPersonNameComponents new];
        
        if (name[@"namePrefix"] && [name[@"namePrefix"] isKindOfClass:[NSString class]]) {
            nameComponents.namePrefix = name[@"namePrefix"];
        }
        
        if (name[@"givenName"] && [name[@"givenName"] isKindOfClass:[NSString class]]) {
            nameComponents.givenName = name[@"givenName"];
        }
        
        if (name[@"middleName"] && [name[@"middleName"] isKindOfClass:[NSString class]]) {
            nameComponents.middleName = name[@"middleName"];
        }
        
        if (name[@"familyName"] && [name[@"familyName"] isKindOfClass:[NSString class]]) {
            nameComponents.familyName = name[@"familyName"];
        }
        
        if (name[@"nameSuffix"] && [name[@"nameSuffix"] isKindOfClass:[NSString class]]) {
            nameComponents.nameSuffix = name[@"nameSuffix"];
        }
        
        if (name[@"nickname"] && [name[@"nickname"] isKindOfClass:[NSString class]]) {
            nameComponents.nameSuffix = name[@"nickname"];
        }
        
        contact.name = nameComponents;
    }
    
    
    if (json[@"phoneNumber"] && [json[@"phoneNumber"] isKindOfClass:[NSString class]]) {
        contact.phoneNumber = [CNPhoneNumber phoneNumberWithStringValue:json[@"phoneNumber"]];
    }
    
    if (json[@"postalAddress"] && [json[@"postalAddress"] isKindOfClass:[NSDictionary class]]) {
        
        CNMutablePostalAddress *postalAddress = [CNMutablePostalAddress new];
        NSDictionary *postalAddressDict = json[@"postalAddress"];
        
        if (postalAddressDict[@"street"] && [postalAddressDict[@"street"] isKindOfClass:[NSString class]]) {
            postalAddress.street = postalAddressDict[@"street"];
        }
        
        if (postalAddressDict[@"city"] && [postalAddressDict[@"city"] isKindOfClass:[NSString class]]) {
            postalAddress.city = postalAddressDict[@"city"];
        }
        
        if (postalAddressDict[@"state"] && [postalAddressDict[@"state"] isKindOfClass:[NSString class]]) {
            postalAddress.state = postalAddressDict[@"state"];
        }
        
        if (postalAddressDict[@"postalCode"] && [postalAddressDict[@"postalCode"] isKindOfClass:[NSString class]]) {
            postalAddress.postalCode = postalAddressDict[@"postalCode"];
        }
        
        if (postalAddressDict[@"country"] && [postalAddressDict[@"country"] isKindOfClass:[NSString class]]) {
            postalAddress.country = postalAddressDict[@"country"];
        }
        
        if (postalAddressDict[@"ISOCountryCode"] && [postalAddressDict[@"ISOCountryCode"] isKindOfClass:[NSString class]]) {
            postalAddress.ISOCountryCode = postalAddressDict[@"ISOCountryCode"];
        }
        
        NSOperatingSystemVersion ios10_3_0 = (NSOperatingSystemVersion){10, 3, 0};
        
        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios10_3_0]) {
            
            if (postalAddressDict[@"subLocality"] && [postalAddressDict[@"subLocality"] isKindOfClass:[NSString class]]) {
                postalAddress.subLocality = postalAddressDict[@"subLocality"];
            }
            
            if (postalAddressDict[@"subAdministrativeArea"] && [postalAddressDict[@"subAdministrativeArea"] isKindOfClass:[NSString class]]) {
                postalAddress.state = json[@"subAdministrativeArea"];
            }
        }
        
        contact.postalAddress = postalAddress;
    }
    
    return contact;
}

@end
