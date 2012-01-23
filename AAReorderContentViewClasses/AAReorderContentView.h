//
//  ReorderContentView.h
//  Test
//
//  Created by Georg Kitz on 12/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
 @abstract  
 @discussion
 */
@interface AAReorderContentView : UIView {
    
    UIImageView *_reorderControl;
    UIView *_startPlaceholderView;
    
    UITableView *_startTableView;
    UITableView *_lastTableView;
    AAReorderCell *_startCell;
    AAReorderCell *_lastCell;
    
    CGPoint _touchStart;
    CGRect _baseRect;
    
    NSInteger _autoScrollValue;
    
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
        unsigned int isAnimating:1;
    }_flags;
    
    NSString *_title;
    __weak id<ReorderDelegate> _delegate;
    AAReorderDrawRect _drawRect;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, weak) id<ReorderDelegate> reorderDelegate;
@property (nonatomic, strong) AAReorderDrawRect drawRect;

- (void)highlightDragOver:(BOOL)highlight animated:(BOOL)animated;  //TODO implement it animated
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;   //TODO implement it animated
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;         //TODO implement it animated
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;           


@end

@protocol ReorderDelegate <NSObject>

- (BOOL)willBeginReorderingForView:(AAReorderContentView *)view;
- (void)didBeginReorderingForView:(AAReorderContentView *)view;

- (BOOL)willEndReorideringForView:(AAReorderContentView *)view
                    fromIndexPath:(NSIndexPath *)fromIndexPath inTable:(UITableView *)fromTableView 
                      toIndexPath:(NSIndexPath *)toIndexPath inTable:(UITableView *)toTableView;
- (void)didEndReorderingForView:(AAReorderContentView *)view 
                  fromIndexPath:(NSIndexPath *)fromIndexPath inTable:(UITableView *)fromTableView 
                    toIndexPath:(NSIndexPath *)toIndexPath inTable:(UITableView *)toTableView;

@end
