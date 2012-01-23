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

@interface AAReorderContentView()

- (BOOL)delegateWillBeginEditing;
- (void)delegateDidBeginEditing;
- (BOOL)delegateWillEndEditing;
- (void)delegateDidEndEditing;

- (void)updateCurrentCellAtPoint:(CGPoint)point;
- (void)updateCurrentTableViewAtPoint:(CGPoint)point inView:(UIView *)view;
- (UIView *)tableSuperview;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AAReorderContentView

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter

@synthesize title = _title;
@synthesize reorderDelegate = _delegate;
@synthesize drawRect = _drawRect;

- (void)setTitle:(NSString *)title{
    _title = title;
    _flags.hasContent = ([_title length] > 0);
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
    [self.superview insertSubview:placeholderView belowSubview:self];
    
    _startPlaceholderView = placeholderView;
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
        
        SMLog(@"IndexPath %@",indexPath);
        if (indexPath.row != 0 && indexPath.row != 6) {
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSetRGBStrokeColor(ctx, 204/255., 151/255., 90/255., 1);
            CGContextSetRGBFillColor(ctx, 204/255., 151/255., 90/255., 0.3);
            CGRect drawingRect = CGRectMake(1, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
            CGContextFillRect(ctx, drawingRect);
        } else if (indexPath.row == 0){
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSetRGBStrokeColor(ctx, 204/255., 151/255., 90/255., 1);
            CGContextSetRGBFillColor(ctx, 204/255., 151/255., 90/255., 0.3);
            CGContextBeginPath(ctx);
            
            CGRect drawingRect = CGRectMake(1, 0, CGRectGetWidth(self.bounds) - 1, CGRectGetHeight(self.bounds));
            CGFloat minX = CGRectGetMinX(drawingRect);
//            CGFloat midX = CGRectGetMidX(drawingRect);
            CGFloat maxX = CGRectGetMaxX(drawingRect);
            
            CGFloat minY = CGRectGetMinY(drawingRect);
//            CGFloat midY = CGRectGetMidY(drawingRect);
            CGFloat maxY = CGRectGetMaxY(drawingRect);
            CGFloat r = 5.;
            
            CGContextMoveToPoint(ctx, minX, minY);
            CGContextAddLineToPoint(ctx, maxX - r, minY);
            CGContextAddArcToPoint(ctx, maxX, minY, maxX, minY + r, r);
            CGContextAddLineToPoint(ctx, maxX, maxY);
            CGContextAddLineToPoint(ctx, minY, maxX);
            
            CGContextClosePath(ctx);
            CGContextDrawPath(ctx, kCGPathFill);
        } else if (indexPath.row == 6){
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSetRGBStrokeColor(ctx, 204/255., 151/255., 90/255., 1);
            CGContextSetRGBFillColor(ctx, 204/255., 151/255., 90/255., 0.3);
            CGContextBeginPath(ctx);
            
            CGRect drawingRect = CGRectMake(1, 0, CGRectGetWidth(self.bounds) - 1, CGRectGetHeight(self.bounds) - 3);
            CGFloat minX = CGRectGetMinX(drawingRect);
//            CGFloat midX = CGRectGetMidX(drawingRect);
            CGFloat maxX = CGRectGetMaxX(drawingRect);
            
            CGFloat minY = CGRectGetMinY(drawingRect);
//            CGFloat midY = CGRectGetMidY(drawingRect);
            CGFloat maxY = CGRectGetMaxY(drawingRect);
            CGFloat r = 5.;
            
            CGContextMoveToPoint(ctx, minX, minY);
            CGContextAddLineToPoint(ctx, maxX, minY);
            CGContextAddLineToPoint(ctx, maxX, maxY - r);
            CGContextAddArcToPoint(ctx, maxX, maxY, maxX - r, maxY, r);
            CGContextAddLineToPoint(ctx, minX, maxY);
            
            CGContextClosePath(ctx);
            CGContextDrawPath(ctx, kCGPathFill); 
        }  
    }
    
    (_flags.selected || _flags.highlighted) ? [[UIColor whiteColor] set] : [[UIColor blackColor] set];
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
