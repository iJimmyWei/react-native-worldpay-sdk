//
//  PKPayment+Serialisation.m
//  RNWorldPay
//
//  Created by Simon Mitchell on 16/05/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "PKPayment+Serialisation.h"
#import "PKContact+Serialisation.h"
#import "PKShippingMethod+Serialisation.h"
#import "PKPaymentToken+Serialisation.h"

@implementation PKPayment (Serialisation)

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *representation = [NSMutableDictionary dictionaryWithDictionary:@{
         @"token": [self.token dictionaryRepresentation],
    }];
    
    if (self.billingContact) {
        representation[@"billingContact"] = [self.billingContact dictionaryRepresentation];
    }
    
    if (self.shippingContact) {
        representation[@"shippingContact"] = [self.shippingContact dictionaryRepresentation];
    }
    
    if (self.shippingMethod) {
        representation[@"shippingMethod"] = [self.shippingMethod dictionaryRepresentation];
    }
    
    return representation;
}

@end
