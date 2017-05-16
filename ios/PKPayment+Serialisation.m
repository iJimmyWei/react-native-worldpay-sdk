//
//  PKPayment+Serialisation.m
//  RNWorldPay
//
//  Created by Simon Mitchell on 16/05/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "PKPayment+Serialisation.h"
#import "PKContact+Serialisation.h"

@implementation PKPayment (Serialisation)

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *representation = [NSMutableDictionary dictionaryWithDictionary:@{
         @"token": self.token,
    }];
    
    if (self.billingContact) {
        representation[@"billingContact"] = [self.billingContact dictionaryRepresentation];
    }
    
    return representation;
}

@end
