#import "RNWorldPay.h"
#import "Worldpay.h"
#import <React/RCTConvert.h>

@implementation RCTConvert (WorldPay)
RCT_ENUM_CONVERTER(WorldpayValidationType, (@{ @"advanced" : @(WorldpayValidationTypeAdvanced),
                                               @"basic" : @(WorldpayValidationTypeBasic)
                                            }),WorldpayValidationTypeBasic, intValue);
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

@end
  
