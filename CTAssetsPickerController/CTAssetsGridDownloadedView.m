/*
 
 MIT License (MIT)
 
 Copyright (c) 2013 Clement CN Tsang
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */

#import <PureLayout/PureLayout.h>
#import "CTAssetsPickerDefines.h"
#import "CTAssetsGridDownloadedView.h"
#import "CTDownloadCheckmark.h"
#import "CTAssetSelectionLabel.h"




@interface CTAssetsGridDownloadedView ()

@property (nonatomic, strong) CTDownloadCheckmark *checkmark;


@end





@implementation CTAssetsGridDownloadedView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self setupViews];
    }
    
    return self;
}


#pragma mark - Setup

- (void)setupViews
{
    self.backgroundColor = CTAssetsGridSelectedViewBackgroundColor;
    self.layer.borderColor = CTAssetsGridSelectedViewTintColor.CGColor;
    
    CTDownloadCheckmark *checkmark = [CTDownloadCheckmark newAutoLayoutView];
   // [checkmark setMargin:3.0f forVerticalEdge:NSLayoutAttributeLeft horizontalEdge:NSLayoutAttributeTop];
    self.checkmark = checkmark;
    [self addSubview:checkmark];
    
}


#pragma mark - Accessors



#pragma mark - Apperance

- (UIColor *)selectedBackgroundColor
{
    return self.backgroundColor;
}

- (void)setSelectedBackgroundColor:(UIColor *)backgroundColor
{
    UIColor *color = (backgroundColor) ? backgroundColor : CTAssetsGridSelectedViewBackgroundColor;
    self.backgroundColor = color;
}

- (CGFloat)borderWidth
{
    return self.layer.borderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (void)setTintColor:(UIColor *)tintColor
{
    UIColor *color = (tintColor) ? tintColor : CTAssetsGridSelectedViewTintColor;
    self.layer.borderColor = color.CGColor;
}



@end
