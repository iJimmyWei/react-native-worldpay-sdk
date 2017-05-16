//
//  PKPaymentToken+Serialisation.m
//  RNWorldPay
//
//  Created by Simon Mitchell on 16/05/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "PKPaymentToken+Serialisation.h"
#import "PKPaymentMethod+Serialisation.h"

@implementation PKPaymentToken (Serialisation)

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *representation = [NSMutableDictionary new];
    
    if (self.paymentMethod) {
        representation[@"paymentMethod"] = [self.paymentMethod dictionaryRepresentation];
    }
    
    if (self.transactionIdentifier) {
        representation[@"transactionIdentifier"] = self.transactionIdentifier;
    }
    
    if (self.paymentData && self.paymentData.length > 0) {
        representation[@"paymentData"] = self.paymentData;
    }
    
    return representation;
}

@end
