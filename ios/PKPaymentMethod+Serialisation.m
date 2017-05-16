//
//  PKPaymentMethod+Serialisation.m
//  RNWorldPay
//
//  Created by Simon Mitchell on 16/05/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "PKPaymentMethod+Serialisation.h"

@implementation PKPaymentPass (Serialisation)

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *representation = [NSMutableDictionary new];
    
    if (self.primaryAccountIdentifier) {
        representation[@"primaryAccountIdentifier"] = self.primaryAccountIdentifier;
    }
    
    if (self.deviceAccountIdentifier) {
        representation[@"deviceAccountIdentifier"] = self.deviceAccountIdentifier;
    }
    if (self.deviceAccountNumberSuffix) {
        representation[@"deviceAccountNumberSuffix"] = self.deviceAccountNumberSuffix;
    }
    if (self.activationState) {
        representation[@"primaryAccountIdentifier"] = self.primaryAccountIdentifier;
    }
    
    switch (self.activationState) {
        case PKPaymentPassActivationStateActivated:
            representation[@"activationState"] = @"activated";
            break;
        case PKPaymentPassActivationStateSuspended:
            representation[@"activationState"] = @"suspended";
            break;
        case PKPaymentPassActivationStateActivating:
            representation[@"activationState"] = @"activating";
            break;
        case PKPaymentPassActivationStateDeactivated:
            representation[@"activationState"] = @"deactivated";
            break;
        case PKPaymentPassActivationStateRequiresActivation:
            representation[@"activationState"] = @"requiresActivation";
            break;
        default:
            break;
    }
    
    return representation;
}

@end

@implementation PKPaymentMethod (Serialisation)

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *representation = [NSMutableDictionary new];
    
    if (self.displayName) {
        representation[@"displayName"] = self.displayName;
    }
    
    if (self.network) {
        representation[@"network"] = self.network;
    }
    
    switch (self.type) {
        case PKPaymentMethodTypeDebit:
            representation[@"type"] = @"debit";
            break;
        case PKPaymentMethodTypeStore:
            representation[@"type"] = @"store";
            break;
        case PKPaymentMethodTypeCredit:
            representation[@"type"] = @"credit";
            break;
        case PKPaymentMethodTypePrepaid:
            representation[@"type"] = @"prepaid";
            break;
        case PKPaymentMethodTypeUnknown:
            representation[@"type"] = @"unknown";
            break;
        default:
            representation[@"type"] = @"unknown";
            break;
    }
    
    if (self.paymentPass) {
        representation[@"paymentPass"] = [self.paymentPass dictionaryRepresentation];
    }
    
    return representation;
}

@end
