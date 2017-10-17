//
//  RNShadowButton.h
//  RNButton
//
//  Created by Simon Mitchell on 23/02/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

@import PassKit;
#import <UIKit/UIKit.h>

#if __has_include(<React/RCTShadowView.h>)
#import <React/RCTShadowView.h>
#elif __has_include("RCTShadowView.h")
#import "RCTShadowView.h"
#elif __has_include("React/RCTShadowView.h")
#import "React/RCTShadowView.h"   // Required when used as a Pod in a Swift project
#endif

@interface RNShadowPaymentButton : RCTShadowView

@property (nonatomic, copy) RCTBubblingEventBlock onPress;

@property (nonatomic, assign) PKPaymentButtonType type;

@property (nonatomic, assign) PKPaymentButtonStyle style;

@end
