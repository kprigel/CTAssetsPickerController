//
//  UIColor+SKDarkMode.h
//  CTAssetsPickerDemo
//
//  Created by Sergey Koval on 18.04.2020.
//  Copyright © 2020 Clement T. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface UIColor (SKDarkMode)

@property (nonatomic, readonly) UIColor *adaptive;

- (UIColor *)adaptiveWithDark:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
