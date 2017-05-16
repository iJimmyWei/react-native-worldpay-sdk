//
//  PKPayment+Serialisation.m
//  RNWorldPay
//
//  Created by Simon Mitchell on 16/05/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "PKPayment+Serialisation.h"

@implementation PKContact (Serialisation)

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *representation = [NSMutableDictionary new];
    
    if (self.name) {
        
        NSMutableDictionary *nameDictionary = [NSMutableDictionary new];
        
        if (self.name.namePrefix) {
            nameDictionary[@"namePrefix"] = self.name.namePrefix;
        }
        
        if (self.name.givenName) {
            nameDictionary[@"givenName"] = self.name.givenName;
        }
        
        if (self.name.middleName) {
            nameDictionary[@"middleName"] = self.name.middleName;
        }
        
        if (self.name.familyName) {
            nameDictionary[@"familyName"] = self.name.familyName;
        }
        
        if (self.name.nameSuffix) {
            nameDictionary[@"nameSuffix"] = self.name.nameSuffix;
        }
        
        if (self.name.nickname) {
            nameDictionary[@"nickname"] = self.name.nickname;
        }
        
        representation[@"name"] = nameDictionary;
    }
    
    if (self.postalAddress) {
        
        NSMutableDictionary *postalAddressDict = [NSMutableDictionary new];
        
        if (self.postalAddress.street) {
            postalAddressDict[@"street"] = self.postalAddress.street;
        }
        
        if (self.postalAddress.city) {
            postalAddressDict[@"city"] = self.postalAddress.city;
        }
        
        if (self.postalAddress.state) {
            postalAddressDict[@"state"] = self.postalAddress.state;
        }
        
        if (self.postalAddress.postalCode) {
            postalAddressDict[@"postalCode"] = self.postalAddress.postalCode;
        }
        
        if (self.postalAddress.country) {
            postalAddressDict[@"country"] = self.postalAddress.country;
        }
        
        if (self.postalAddress.ISOCountryCode) {
            postalAddressDict[@"ISOCountryCode"] = self.postalAddress.ISOCountryCode;
        }
        
        NSOperatingSystemVersion ios10_3_0 = (NSOperatingSystemVersion){10, 3, 0};
        
        if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:ios10_3_0]) {
            
            if (self.postalAddress.subLocality) {
                postalAddressDict[@"subLocality"] = self.postalAddress.subLocality;
            }
            
            if (self.postalAddress.subAdministrativeArea) {
                postalAddressDict[@"subAdministrativeArea"] = self.postalAddress.subAdministrativeArea;
            }
        }
    }
    
    if (self.emailAddress) {
        representation[@"emailAddress"] = self.emailAddress;
    }
    
    if (self.phoneNumber) {
        representation[@"phoneNumber"] = self.phoneNumber.stringValue;
    }
    
    return representation;
}

@end
