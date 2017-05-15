//
//  RNPaymentButton.m
//  RNWorldPay
//
//  Created by Simon Mitchell on 15/05/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNPaymentButton.h"

@implementation RNPaymentButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.button = [[PKPaymentButton alloc] initWithPaymentButtonType:PKPaymentButtonTypePlain paymentButtonStyle:PKPaymentButtonStyleBlack];
        [self.button addTarget:self action:@selector(handleButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
    }
    return self;
}

- (void)sizeToFit
{
    [self.button sizeToFit];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.button.frame.size.width, self.button.frame.size.height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.button.frame = self.bounds;
}

- (void)setStyle:(PKPaymentButtonStyle)style
{
    if (_style != style) {
        [self.button removeFromSuperview];
        self.button = [[PKPaymentButton alloc] initWithPaymentButtonType:self.type paymentButtonStyle:style];
        [self.button addTarget:self action:@selector(handleButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
        [self setNeedsLayout];
    }
    _style = style;
}

- (void)setType:(PKPaymentButtonType)type
{
    if (_type != type) {
        [self.button removeFromSuperview];
        self.button = [[PKPaymentButton alloc] initWithPaymentButtonType:type paymentButtonStyle:self.style];
        [self.button addTarget:self action:@selector(handleButtonPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.button];
        [self setNeedsLayout];
    }
    _type = type;
}

- (void)handleButtonPress:(PKPaymentButton *)sender
{
    if ([sender.superview isKindOfClass:[RNPaymentButton class]]) {
        
        RNPaymentButton *paymentButton = (RNPaymentButton *)sender.superview;
        if (paymentButton.onPress) {
            paymentButton.onPress(@{});
        }
    }
}

@end
