//
//    AAReorderCell.h
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
#import "AAReorderContentView.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*!
 @class       DayCell
 @abstract    
 @discussion
 */
 
@interface AAReorderCell : UITableViewCell {
    
    AAReorderContentView *_reorderView;
    UITableViewCellStateMask _oldState;
}

/** displayed title */
@property (nonatomic, strong) NSString *title; 

/** current reorderview **/
@property (nonatomic, strong) AAReorderContentView *reorderingView;

/** ReorderDelegate, see AAReorderContentView.h for details */
@property (nonatomic, weak) id<ReorderDelegate> reorderDelegate;

/** Rect of the reorderview inside the contentview, when editing is enabled */
@property (nonatomic, readonly) CGRect reorderRect;

/** Highlights the underlying reorderview when you drag over it */
- (void)highlightedDragOver:(BOOL)highlight animated:(BOOL)animated;

@end
