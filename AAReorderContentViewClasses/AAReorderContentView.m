//
//    ReorderContentView.m
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

#import "AAReorderContentView.h"
#import "AAPlaceholderReorderView.h"
#import "AAReorderCell.h"

typedef enum {
    AAReorderCellCornerTypeNone = 0,
    AAReorderCellCornerTypeLeftTop = 1,
    AAReorderCellCornerTypeRightTop = 2,
    AAReorderCellCornerTypeRightBottom = 4,
    AAReorderCellCornerTypeLeftBottom = 8,
    AAReorderCellConrerTypeRoundRect = (AAReorderCellCornerTypeLeftTop | AAReorderCellCornerTypeRightTop | 
                                        AAReorderCellCornerTypeRightBottom | AAReorderCellCornerTypeLeftBottom)
}AAReorderCellCornerType;

@interface AAReorderContentView()

- (BOOL)delegateWillBeginEditing;
- (void)delegateDidBeginEditing;
- (BOOL)delegateWillEndEditing;
- (void)delegateDidEndEditing;

- (void)updateCurrentCellAtPoint:(CGPoint)point;
- (void)updateCurrentTableViewAtPoint:(CGPoint)point inView:(UIView *)view;
- (UIView *)tableSuperview;

- (void)drawRectHighlightWithCornerType:(AAReorderCellCornerType)cornerType;

- (void)startAutoScrolling;
- (void)stopAutoScrolling;
@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AAReorderContentView

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter

@synthesize title = _title;
@synthesize reorderDelegate = _delegate;
@synthesize drawRect = _drawRect;

@synthesize titleColor = _titleColor;
@synthesize titleHighlightedColor = _titleHighlightedColor;
@synthesize draggingHighlightedColor = _draggingHighlightedColor;
@synthesize draggingPlaceholderColor = _draggingPlaceholderColor;
@synthesize draggingHighlightedBorderColor = _draggingHighlightedBorderColor;

- (void)setTitle:(NSString *)title{
    _title = title;
    _flags.hasContent = ([_title length] > 0);
    
    if (!_flags.hasContent && _flags.editing) {
        [_reorderControl removeFromSuperview];
    }
}

- (void)setReorderDelegate:(id<ReorderDelegate>)reorderDelegate{
    _delegate = reorderDelegate;
    _flags.delegateWillBeginReordering = [_delegate respondsToSelector:@selector(willBeginReorderingForView:)];
    _flags.delegateDidBeginReordering = [_delegate respondsToSelector:@selector(didBeginReorderingForView:)];
    _flags.delegateWillEndReordering = [_delegate respondsToSelector:@selector(willEndReorideringForView:fromIndexPath:inTable:toIndexPath:inTable:)];
    _flags.delegateDidEndReordering = [_delegate respondsToSelector:@selector(didEndReorderingForView:fromIndexPath:inTable:toIndexPath:inTable:)];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

- (BOOL)delegateWillBeginEditing{
    if (_flags.delegateWillBeginReordering) {
        return [_delegate willBeginReorderingForView:self];
    }
    return YES;
}

- (void)delegateDidBeginEditing{
    if (_flags.delegateDidBeginReordering) {
        [_delegate didBeginReorderingForView:self];
    }
}

- (BOOL)delegateWillEndEditing{
    if (_flags.delegateWillEndReordering) {
        NSIndexPath *fromIndexPath = [_startTableView indexPathForCell:_startCell];
        NSIndexPath *toIndexPath = [_lastTableView indexPathForCell:_lastCell];
        return [_delegate willEndReorideringForView:self fromIndexPath:fromIndexPath inTable:_startTableView toIndexPath:toIndexPath inTable:_lastTableView];
    }
    return YES;
}

- (void)delegateDidEndEditing{
    if (_flags.delegateDidEndReordering) {
        UITableViewCell *cell = (_lastCell == nil) ? _startCell : _lastCell;
        
        NSIndexPath *fromIndexPath = [_startTableView indexPathForCell:_startCell];
        NSIndexPath *toIndexPath = [_lastTableView indexPathForCell:cell];
        
        [_delegate didEndReorderingForView:self fromIndexPath:fromIndexPath inTable:_startTableView toIndexPath:toIndexPath inTable:_lastTableView];
    }
}

- (void)updateCurrentCellAtPoint:(CGPoint)point{
    NSIndexPath *indexPath = [_lastTableView indexPathForRowAtPoint:point];
    AAReorderCell *cell = (AAReorderCell *)[_lastTableView cellForRowAtIndexPath:indexPath];
    
    if (_lastCell == cell) {
        return;
    }
    
    [cell highlightedDragOver:YES animated:YES];
    
    if (_lastCell) {
        [_lastCell highlightedDragOver:NO animated:YES];
    } 
    
    _lastCell = cell;
}

- (void)updateCurrentTableViewAtPoint:(CGPoint)point inView:(UIView *)view{
    
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UITableView class]]) {
            
            CGRect frame = subview.frame;
            if (CGRectContainsPoint(frame, point)){
                
                if (_lastTableView == subview) {
                    continue;
                }
                
                _lastTableView.scrollEnabled = YES;
                _lastTableView = (UITableView *)subview;
                _lastTableView.scrollEnabled = NO;
                
                return;
            }
        }
    }    
}

- (UIView *)tableSuperview{
    BOOL isTableView = NO;
    UIView *view = self;
    
    while (isTableView == NO) {
        view = view.superview;
        
        if ([view isKindOfClass:[AAReorderCell class]]) {
            _startCell = (AAReorderCell *)view;
        }
        
        if ([view isKindOfClass:[UITableView class]]) {
            isTableView = YES;
            
            _startTableView = (UITableView *)view;
            _startTableView.scrollEnabled = NO;
            _lastTableView = _startTableView;
        }
    }
    
    if (isTableView) {
        return [view superview];
    }
    return nil;
}

- (void)setupPlaceholderView{
    AAPlaceholderReorderView *placeholderView = [[AAPlaceholderReorderView alloc] initWithFrame:self.frame];
    placeholderView.title = self.title;
    placeholderView.color = _draggingPlaceholderColor;
    [self.superview insertSubview:placeholderView belowSubview:self];
    
    _startPlaceholderView = placeholderView;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark AutoScrolling Methods 

//- (void)autoscroll:(NSTimer *)timer{
//    
//    if (!_flags.shouldAutoScroll || _flags.isAnimating) {
//        return;
//    }
//    
//    CGPoint point = _scrollView.contentOffset;
//    point.x += (_autoScrollValue * 320);
//    
//    if (point.x + CGRectGetWidth(_scrollView.frame) > _scrollView.contentSize.width || point.x < 0) {
//        _flags.shouldAutoScroll = NO;
//        return;
//    }
//    
//    _flags.isAnimating = YES;
//    _flags.shouldAutoScroll = NO;
//    
//    [UIView animateWithDuration:0.25 animations:^{
//        [_scrollView setContentOffset:point animated:NO];
//    } completion:^(BOOL finished) {
//        _flags.isAnimating = NO;
//    }];
//    
//    [self findTableViewAtPoint:CGPointMake(point.x, 160) inView:_scrollView];
//    [self findCurrentAtPoint:self.center];
//}


- (void)internalShouldAutoScroll{
    if (!_flags.shouldAutoScroll){
        return;
    }
    
    [_lastTableView setContentOffset:CGPointMake(0,_lastTableView.contentOffset.y + 1) animated:YES];
    [self performSelectorOnMainThread:@selector(internalShouldAutoScroll) withObject:nil waitUntilDone:NO];
}

- (void)startAutoScrolling{
    _flags.shouldAutoScroll = YES;
    [self performSelectorOnMainThread:@selector(internalShouldAutoScroll) withObject:nil waitUntilDone:NO];
}

- (void)stopAutoScrolling{
    _flags.shouldAutoScroll = NO;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Notifications Methods

- (void)draggingBeganNotification{
    if (!_flags.hasContent && !_flags.reorderingTapped) {
        _flags.dragHighlighting = YES;
        _flags.dragOverHighlighting = NO;
        [self setNeedsDisplay];
    }
}

- (void)draggingEndNotification{
    _flags.dragOverHighlighting = NO;
    _flags.dragHighlighting = NO;
    [self setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization

- (id)init {
	if(self = [super init]) {
		// Initialization code

	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
        _flags.reorderingTapped = NO;
        _flags.dragHighlighting = NO;
        
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _reorderControl = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(frame) - 30, 0, 30, CGRectGetHeight(frame))];
        _reorderControl.image = [UIImage imageNamed:@"reorder_handle"];
        _reorderControl.contentMode = UIViewContentModeCenter;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(draggingBeganNotification) name:kDraggingBeganNotifivation object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(draggingEndNotification) name:kDraggingEndNotification object:nil];
        
        self.titleColor = [UIColor blackColor];
        self.titleHighlightedColor = [UIColor whiteColor];
        self.draggingHighlightedColor = [UIColor colorWithRed:204/255. green:151/255. blue:90/255. alpha:0.3]; 
        self.draggingHighlightedBorderColor = [UIColor colorWithRed:204/255. green:151/255. blue:90/255. alpha:1.]; 
        self.draggingPlaceholderColor = [UIColor colorWithRed:204/255. green:151/255. blue:90/255. alpha:0.4];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

- (void)highlightDragOver:(BOOL)highlight animated:(BOOL)animated{
    
    if (_flags.reorderingTapped) {
        return;
    }
    
    _flags.dragOverHighlighting = highlight;
    [self setNeedsDisplay];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    
    if ([_title length] == 0 && editing) {
        return;
    }
    
    _flags.editing = editing;
    self.userInteractionEnabled = editing;

    if (editing) { 
        [self addSubview:_reorderControl];
        
        if (animated) {
            _reorderControl.alpha = 0.0;
            [UIView animateWithDuration:0.3 animations:^{
                _reorderControl.alpha = 1.0; 
            }];
        }
    } else {
        
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                _reorderControl.alpha = 0.0;
            } completion:^(BOOL finished) {
                [_reorderControl removeFromSuperview];
            }];
        } else {
            [_reorderControl removeFromSuperview];
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    _flags.highlighted = highlighted;
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    _flags.selected = selected;
    [self setNeedsDisplay];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Overridden Methods

/*
// Only override layoutSubviews: if it is necessary
// An empty implementation adversely affects performance during animation.
- (void)layoutSubviews {
    [super layoutSubviews];
    // layout code
}
*/

- (void)drawRectHighlightWithCornerType:(AAReorderCellCornerType)cornerType{

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, _draggingHighlightedBorderColor.CGColor);
    CGContextSetFillColorWithColor(ctx, _draggingHighlightedColor.CGColor);
    
    CGRect drawingRect = CGRectInset(self.bounds, 2, 2);
    
    if (cornerType == AAReorderCellCornerTypeNone) {
        CGContextStrokeRect(ctx, drawingRect);
        CGContextFillRect(ctx, drawingRect);
        return;
    }
    
    CGContextBeginPath(ctx);
    
    CGFloat minX = CGRectGetMinX(drawingRect);
    CGFloat midX = CGRectGetMidX(drawingRect);
    CGFloat maxX = CGRectGetMaxX(drawingRect);
    
    CGFloat minY = CGRectGetMinY(drawingRect);
    CGFloat midY = CGRectGetMidY(drawingRect);
    CGFloat maxY = CGRectGetMaxY(drawingRect);
    CGFloat radius = 10.;
    CGFloat r = 0;
    
    CGContextMoveToPoint(ctx, minX, midY);
    r = (cornerType & AAReorderCellCornerTypeLeftTop ? radius : 0); // TOP LEFT
    CGContextAddArcToPoint(ctx, minX, minY, midX, minY, r);
    
    r = (cornerType & AAReorderCellCornerTypeRightTop ? radius : 0); //TOP RIGHT
    CGContextAddArcToPoint(ctx, maxX, minY, maxX, midY, r);
    
    r = (cornerType & AAReorderCellCornerTypeRightBottom ? radius : 0); //BOTTOM RIGHT
    CGContextAddArcToPoint(ctx, maxX, maxY, midX, maxY, r);
    
    r = (cornerType & AAReorderCellCornerTypeLeftBottom ? radius : 0); // BOTTOM LEFT
    CGContextAddArcToPoint(ctx, minX, maxY, minX, midY, r);
    
    CGContextClosePath(ctx);
    CGContextDrawPath(ctx, kCGPathFillStroke);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    if (_drawRect) {
        _drawRect(rect);
        return;
    }
        
    if (_flags.dragOverHighlighting) {
        
        if (_startTableView == nil) {
            [self tableSuperview];
        }
        
        NSIndexPath *indexPath = [_startTableView indexPathForCell:_startCell];
        NSInteger numberOfRows = [_startTableView numberOfRowsInSection:0];
        AAReorderCellCornerType cornerType = AAReorderCellCornerTypeNone;
        if ( indexPath.row == 0 && indexPath.row == numberOfRows - 1 ) {
            cornerType = AAReorderCellCornerTypeRightTop | AAReorderCellCornerTypeRightBottom;
        } else if ( indexPath.row == 0 ){
            cornerType = AAReorderCellCornerTypeRightTop;
        } else if ( indexPath.row == numberOfRows - 1){
            cornerType = AAReorderCellCornerTypeRightBottom;
        }
        
        SMLog(@"IndexPath %@",indexPath);
        [self drawRectHighlightWithCornerType:cornerType];
    }
    
    (_flags.selected || _flags.highlighted) ? [_titleHighlightedColor set] : [_titleColor set];
    [_title drawInRect:CGRectMake(0, CGRectGetHeight(self.frame) / 2 - 11, CGRectGetWidth(self.frame) - 34, 22) withFont:[UIFont systemFontOfSize:17] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (![self delegateWillBeginEditing]) {
        [self.nextResponder touchesBegan:touches withEvent:event];
        return;
    }
    
    UITouch *touch = [touches anyObject];    
    CGPoint touchPoint = [touch locationInView:self];
    
    if (CGRectContainsPoint(_reorderControl.frame, touchPoint) && _flags.reorderingTapped == NO) {

        _flags.reorderingTapped = YES;
        UIView *superView = [self tableSuperview];
        [_startTableView setScrollEnabled:NO];
        
        //Add Placeholder View
        [self setupPlaceholderView];
        
        CGRect rect = [self.superview convertRect:self.frame toView:superView];
        self.frame = rect;
        [superView addSubview:self];
        
        _baseRect = rect;
        _touchStart = [touch locationInView:self];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDraggingBeganNotifivation object:nil];
        [self delegateDidBeginEditing];
        
    } else {
        [self.nextResponder touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (_flags.reorderingTapped) {
        
        CGPoint point = [[touches anyObject] locationInView:self];
        self.center = CGPointMake(self.center.x + point.x - _touchStart.x, self.center.y + point.y - _touchStart.y);  
        
        [self updateCurrentTableViewAtPoint:self.center inView:self.superview];
        
        point = [[touches anyObject] locationInView:_lastTableView];
        [self updateCurrentCellAtPoint:point];
        
        CGRect autoScrollingRect = CGRectMake(CGRectGetMinX(_lastTableView.frame), CGRectGetMaxY(_lastTableView.frame) - _lastTableView.rowHeight, CGRectGetWidth(_lastTableView.frame), _lastTableView.rowHeight);
        

        if (CGRectIntersectsRect(self.frame, autoScrollingRect) && !_flags.shouldAutoScroll) {
            SMLog(@"INTERSECT");
            [self startAutoScrolling];
        } else if(!CGRectIntersectsRect(self.frame, autoScrollingRect) && _flags.shouldAutoScroll){
            [self stopAutoScrolling];
        }
    } 
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

    if (!_flags.reorderingTapped || ![self delegateWillEndEditing]) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDraggingEndNotification object:nil];
    _flags.dragHighlighting = NO;
    _flags.dragOverHighlighting = NO;
    _flags.reorderingTapped = NO;
    _lastTableView.scrollEnabled = _startTableView.scrollEnabled = YES;
    
    if (_lastCell != nil && _lastCell != _startCell) {

        CGRect animationFrame = _lastCell.reorderRect;
        CGRect frame = [_lastCell.contentView convertRect:animationFrame toView:self.superview];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = frame;
        } completion:^(BOOL finished) {
            
            [_lastCell.reorderingView removeFromSuperview];
            _lastCell.reorderingView = nil;

            [self removeFromSuperview];
            _lastCell.reorderingView = self;
            
            _startCell.reorderingView = [[AAReorderContentView alloc] initWithFrame:CGRectZero];
            _startCell.reorderingView.reorderDelegate = _delegate ;
            
            [self delegateDidEndEditing];
            
            [_startPlaceholderView removeFromSuperview];
        }];
        
        return;
    }
    
    //When last Cell was nil or lastCell is same cell as start cell
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = _baseRect;
    } completion:^(BOOL finished) {

        AAReorderCell *cell = _startCell;
        
        [cell.reorderingView removeFromSuperview];
        cell.reorderingView = nil;

        [self removeFromSuperview];
        cell.reorderingView = self;
        
        [self delegateDidEndEditing];
        
        [_startPlaceholderView removeFromSuperview];
    }];
}

@end
