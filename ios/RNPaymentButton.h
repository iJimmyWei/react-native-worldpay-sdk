//
//  RNPaymentButton.h
//  RNWorldPay
//
//  Created by Simon Mitchell on 15/05/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

@import PassKit;
#import <React/RCTComponent.h>

@interface RNPaymentButton : UIView

@property (nonatomic, copy) RCTBubblingEventBlock onPress;

@property (nonatomic, strong) PKPaymentButton *button;

@property (nonatomic, assign) PKPaymentButtonType type;

@property (nonatomic, assign) PKPaymentButtonStyle style;

@end
