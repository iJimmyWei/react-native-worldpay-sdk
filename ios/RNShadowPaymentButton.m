//
//  RNShadowButton.m
//  RNButton
//
//  Created by Simon Mitchell on 23/02/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "RNShadowPaymentButton.h"
#import "RNPaymentButton.h"

#if __has_include(<React/RCTUtils.h>)
#import <React/RCTUtils.h>
#elif __has_include("RCTUtils.h")
#import "RCTUtils.h"
#elif __has_include("React/RCTUtils.h")
#import "React/RCTUtils.h"   // Required when used as a Pod in a Swift project
#endif

#if __has_include(<React/RCTUIManager.h>)
#import <React/RCTUIManager.h>
#elif __has_include("RCTUIManager.h")
#import "RCTUIManager.h"
#elif __has_include("React/RCTUIManager.h")
#import "React/RCTUIManager.h"   // Required when used as a Pod in a Swift project
#endif

@interface RNShadowPaymentButton ()

@property (nonatomic, strong) RNPaymentButton *button;

@end

@implementation RNShadowPaymentButton

- (instancetype)init
{
    if ((self = [super init])) {
        
        self.button = [RNPaymentButton new];
        YGNodeSetMeasureFunc(self.yogaNode, RCTMeasure);
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(contentSizeMultiplierDidChange:)
                                                     name:RCTUIManagerWillUpdateViewsDueToContentSizeMultiplierChangeNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isCSSLeafNode
{
    return true;
}

static YGSize RCTMeasure(YGNodeRef node, float width, YGMeasureMode widthMode, float height, YGMeasureMode heightMode)
{
    RNShadowPaymentButton *shadowButton = (__bridge RNShadowPaymentButton *)YGNodeGetContext(node);
    
    [shadowButton.button sizeToFit];
    
    CGSize computedSize = shadowButton.button.frame.size;
    
    YGSize result;
    result.width = RCTCeilPixelValue(computedSize.width);
    result.height = RCTCeilPixelValue(computedSize.height);
    
    return result;
}

- (void)contentSizeMultiplierDidChange:(NSNotification *)note
{
    YGNodeMarkDirty(self.yogaNode);
    [self.button setNeedsLayout];
}

- (NSDictionary<NSString *,id> *)processUpdatedProperties:(NSMutableSet<RCTApplierBlock> *)applierBlocks parentProperties:(NSDictionary<NSString *,id> *)parentProperties
{
    parentProperties = [super processUpdatedProperties:applierBlocks parentProperties:parentProperties];
    
    __weak typeof(self) welf = self;
    
    [applierBlocks addObject:^(NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        
        RNPaymentButton *button = (RNPaymentButton *)viewRegistry[self.reactTag];
        
        [UIView transitionWithView:button duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

            button.onPress = welf.onPress;
            button.type = welf.type;
            button.style = welf.style;
            
        } completion:nil];
    }];
    
    return parentProperties;
}

- (void)setOnPress:(RCTBubblingEventBlock)onPress
{
    _onPress = onPress;
    [self.button setOnPress:onPress];
    [self dirtyPropagation];
}

- (void)setType:(PKPaymentButtonType)type
{
    _type = type;
    [self.button setType:type];
    [self dirtyPropagation];
}

- (void)setStyle:(PKPaymentButtonStyle)style
{
    _style = style;
    [self.button setStyle:style];
    [self dirtyPropagation];
}

@end
