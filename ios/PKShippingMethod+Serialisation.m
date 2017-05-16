//
//  PKPayment+Serialisation.m
//  RNWorldPay
//
//  Created by Simon Mitchell on 16/05/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "PKShippingMethod+Serialisation.h"

@implementation PKShippingMethod (Serialisation)

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *representation = [NSMutableDictionary dictionaryWithDictionary:@{
         @"label": self.label,
         @"amount": self.amount,
         @"type": self.type == PKPaymentSummaryItemTypeFinal ? @"final" : @"pending"
    }];
    
    if (self.detail) {
        representation[@"description"] = self.detail;
    }
    
    if (self.identifier) {
        representation[@"identifier"] = self.identifier;
    }
    
    return representation;
}

@end
