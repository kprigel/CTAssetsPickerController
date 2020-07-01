//
//  UIColor+SKDarkMode.m
//  CTAssetsPickerDemo
//
//  Created by Sergey Koval on 18.04.2020.
//  Copyright © 2020 Clement T. All rights reserved.
//

#import "UIColor+SKDarkMode.h"

// colors reference and good article
// https://nshipster.com/dark-mode/


@implementation UIColor (SKDarkMode)

- (UIColor *)adaptive
{
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traits) {
            if (traits.userInterfaceStyle != UIUserInterfaceStyleDark) {
                return self;
            }

            if (self == [UIColor blackColor]) {
                return [UIColor systemGrayColor];
            } else if (self == [UIColor darkGrayColor]) {
                return [UIColor systemGray2Color];
            } else if (self == [UIColor lightGrayColor]) {
                return [UIColor systemGray4Color];
            } else if (self == [UIColor whiteColor]) {
                return [UIColor systemGray6Color];
            } else if (self == [UIColor grayColor]) {
                return [UIColor systemGray3Color];
            } else if (self == [UIColor redColor]) {
                return [UIColor systemRedColor];
            } else if (self == [UIColor greenColor]) {
                return [UIColor systemGreenColor];
            } else if (self == [UIColor blueColor]) {
                return [UIColor systemIndigoColor];
            } else if (self == [UIColor cyanColor]) {
                return [UIColor systemBlueColor];
            } else if (self == [UIColor yellowColor]) {
                return [UIColor systemYellowColor];
            } else if (self == [UIColor magentaColor]) {
                return [UIColor systemPinkColor];
            } else if (self == [UIColor orangeColor]) {
                return [UIColor systemOrangeColor];
            } else if (self == [UIColor purpleColor]) {
                return [UIColor systemPurpleColor];
            } else if (self == [UIColor brownColor]) {
                return [UIColor colorWithRed:0.770 green:0.510 blue:0.310 alpha:1.0];
            } else if (self == [UIColor clearColor]) {
                return [UIColor clearColor];
            } else if (self == [UIColor darkTextColor]) {
                return [UIColor labelColor];
            } else if (self == [UIColor lightTextColor]) {
                return [UIColor systemGray6Color];
            } else {
                CGFloat hue;
                CGFloat saturation;
                CGFloat brightness;
                CGFloat alpha;
                [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
                return [UIColor colorWithHue:hue saturation:saturation brightness:brightness - 0.3 alpha:alpha];
            }
        }];
    } else {
        return self;
    }
}

- (UIColor *)adaptiveWithDark:(UIColor *)color
{
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor *(UITraitCollection *traits) {
            return traits.userInterfaceStyle == UIUserInterfaceStyleDark ? color : self;
        }];
    } else {
        return self;
    }
}

@end
