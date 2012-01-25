//
//    AAReorderContentView.h
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

#define AA_REORDER_DEBUG 1

#ifdef AA_REORDER_DEBUG
#define SMLog NSLog
#else
#define SMLog
#endif

#define SMLogRect(rect) \
SMLog(@"x = %4.f, y = %4.f, w = %4.f, h = %4.f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)

#define SMLogPoint(pt) \
SMLog(@"x = %4.f, y = %4.f", pt.x, pt.y)

#define SMLogSize(size) \
SMLog(@"w = %4.f, h = %4.f", size.width, size.height)

#define kDraggingBeganNotifivation @"aa.reorder.dragging.began"
#define kDraggingEndNotification @"aa.reorder.dragging.end"

@class AAReorderCell;
@protocol ReorderDelegate;

typedef void(^AAReorderDrawRect)(CGRect);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*!
 @class       ReorderContentView
 @abstract    This view is used for the whole reorder stuff.
 */
@interface AAReorderContentView : UIView {
    
    UIImageView *_reorderControl;
    UIView *_startPlaceholderView;
    
    UITableView *_startTableView;
    UITableView *_lastTableView;
    AAReorderCell *_startCell;
    AAReorderCell *_lastCell;
    
    NSIndexPath *_startIndexPath;
    
    CGPoint _touchStart;
    CGRect _baseRect;
    
    struct {
        unsigned int hasContent:1;                      //title length != 0
        unsigned int reorderingTapped:1;
        unsigned int dragHighlighting:1;
        unsigned int dragOverHighlighting:1;
        unsigned int delegateWillBeginReordering:1;
        unsigned int delegateDidBeginReordering:1;
        unsigned int delegateWillEndReordering:1;
        unsigned int delegateDidEndReordering:1;
        unsigned int editing:1;
        unsigned int highlighted:1;
        unsigned int selected:1;
        unsigned int shouldAutoScroll:1;
        unsigned int autoscrollDirection:3;
        unsigned int isAnimating:1;
        unsigned int shouldShowPlaceholderView:1;
    }_flags;
    
    //Properties
    NSString *_title;
    __weak id<ReorderDelegate> _delegate;
    AAReorderDrawRect _drawRect;
    
    //Style
    UIColor *_titleColor;
    UIColor *_titleHighlightedColor;
    UIColor *_draggingPlaceholderColor;
    UIColor *_draggingHighlightedColor;
    UIColor *_draggingHighlightedBorderColor;
}

/** display title of the reorderview */
@property (nonatomic, strong) NSString *title;

@property (nonatomic, weak) id<ReorderDelegate> reorderDelegate;

/** to override the current drawRect just set this block */
@property (nonatomic, strong) AAReorderDrawRect drawRect;

@property (nonatomic, strong) NSIndexPath *startIndexPath; 
@property (nonatomic, assign) BOOL showPlaceholderView;

/** Style properties */
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *titleHighlightedColor;
@property (nonatomic, strong) UIColor *draggingPlaceholderColor; 
@property (nonatomic, strong) UIColor *draggingHighlightedColor; 
@property (nonatomic, strong) UIColor *draggingHighlightedBorderColor; 

- (void)highlightDragOver:(BOOL)highlight animated:(BOOL)animated;  //TODO implement it animated
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;   //TODO implement it animated
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;         //TODO implement it animated
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;           

@end

@protocol ReorderDelegate <NSObject>
@optional
/** allows reoder for a certain reoderview or not. Is called in touchesBegan: 
 @return YES/NO wether reordering is allowed or not, default is YES
 */
- (BOOL)willBeginReorderingForView:(AAReorderContentView *)view;

/** called as soon at the end of touchesBegan, right before touchesMove get called */
- (void)didBeginReorderingForView:(AAReorderContentView *)view;

/** called at the begin of touches end, when a user removes his finger from the reorder control. 
    You can check in this method wether it is allowed to set the contentview to the destination cell or not
    @return YES when it is allowed or NO.
 */
- (BOOL)willEndReorideringForView:(AAReorderContentView *)view
                    fromIndexPath:(NSIndexPath *)fromIndexPath inTable:(UITableView *)fromTableView 
                      toIndexPath:(NSIndexPath *)toIndexPath inTable:(UITableView *)toTableView;

/** called when the reorderview is set to the new reordercell
 * you should update your datasource as soon as this method gets called.
 */
- (void)didEndReorderingForView:(AAReorderContentView *)view 
                  fromIndexPath:(NSIndexPath *)fromIndexPath inTable:(UITableView *)fromTableView 
                    toIndexPath:(NSIndexPath *)toIndexPath inTable:(UITableView *)toTableView;

@end
