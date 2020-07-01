/*
 
 MIT License (MIT)
 
 Copyright (c) 2015 Clement CN Tsang
 
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

/* Default size */

#define CTAssetCollectionThumbnailLengh             70.0f
#define CTAssetCollectionThumbnailSize              CGSizeMake(CTAssetCollectionThumbnailLengh, CTAssetCollectionThumbnailLengh)

#define CTAssetsPickerPopoverContentSize            CGSizeMake(695.0f, 580.0f)



/* Default appearance */

#define CTAssetsPikcerAccessDeniedViewTextColor     [[UIColor colorWithRed:129.0f/255.0f green:136.0f/255.0f blue:148.0f/255.0f alpha:1] adaptive]
#define CTAssetsPickerNoAssetsViewTextColor         [[UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1] adaptive]

#define CTAssetsPikcerThumbnailTintColor            [[UIColor colorWithRed:164.0f/255.0f green:164.0f/255.0f blue:164.0f/255.0f alpha:1] adaptive]
#define CTAssetsPikcerThumbnailBackgroundColor      [[UIColor colorWithRed:235.0f/255.0f green:235.0f/255.0f blue:235.0f/255.0f alpha:1] adaptive]

#define CTAssetCollectionViewCellTitleFont          [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
#define CTAssetCollectionViewCellTitleTextColor     [[UIColor darkTextColor] adaptive]
#define CTAssetCollectionViewCellCountFont          [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1]
#define CTAssetCollectionViewCellCountTextColor     [[UIColor darkTextColor] adaptive]
#define CTAssetCollectionViewCellAccessoryColor     [[UIColor colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:193.0f/255.0f alpha:1] adaptive]

#define CTAssetsGridViewBackgroundColor             [[UIColor whiteColor] adaptive]

#define CTAssetsGridViewCellDisabledColor           [[UIColor colorWithWhite:1 alpha:0.8] adaptive]
#define CTAssetsGridViewCellHighlightedColor        [[UIColor colorWithWhite:0 alpha:0.5] adaptive]

#define CTAssetsGridSelectedViewBackgroundColor     [[UIColor colorWithWhite:1 alpha:0.3] adaptive]
#define CTAssetsGridSelectedViewTintColor           [UIView new].tintColor

#define CTAssetLabelSize                            CGSizeMake(25.0f, 25.0f)
#define CTAssetLabelFont                            [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
#define CTAssetLabelTextColor                       [[UIColor whiteColor] adaptive]
#define CTAssetLabelBackgroundColor                 [UIView new].tintColor
#define CTAssetLabelBorderColor                     [[UIColor whiteColor] adaptive]

#define CTAssetsGridViewFooterFont                  [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
#define CTAssetsGridViewFooterTextColor             [[UIColor darkTextColor] adaptive]

#define CTAssetsPageViewPageBackgroundColor         [[UIColor whiteColor] adaptive]
#define CTAssetsPageViewFullscreenBackgroundColor   [[UIColor blackColor] adaptive]

