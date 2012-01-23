//
//    AAPlaceholderReorderView.h
//    
//    Created by Georg Kitz 20.01.2012
//    Copyright (C) 2012, Georg Kitz, @gekitz, http://www.aurora-apps.com , All rights reserved.
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy of
//    this software and associated documentation files (the "Software"), to deal in
//    the Software without restriction, including without limitation the rights to
//    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
//    of the Software, and to permit persons to whom the Software is furnished to do
//    so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/**
 @class       PlaceholderReorderView
 @abstract    When a user starts dragging a contentview, this view is show as a placeholder view at the start point. 
 */
@interface AAPlaceholderReorderView : UIView {
    NSString *_title;
    UIColor *_color;
}

/** same title as the AAReorderContentView title */
@property (nonatomic, strong) NSString *title; 

/** placeholder color, default color is [UIColor colorWithRed:204/255. green:151/255. blue:90/255. alpha:0.4] */
@property (nonatomic, strong) UIColor *color;

@end
