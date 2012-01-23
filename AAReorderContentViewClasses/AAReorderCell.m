//
//    AAReorderCell.m
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

#import "AAReorderCell.h"

@implementation AAReorderCell

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter

@dynamic reorderDelegate;
@synthesize reorderingView = _reorderView;

- (void)setReorderingView:(AAReorderContentView *)reorderingView{
    _reorderView = reorderingView;
    _reorderView.frame = [self reorderRect];
    [self.contentView addSubview:_reorderView];
}

- (void)setTitle:(NSString *)title{
    _reorderView.title = title;
}

- (NSString *)title{
    return _reorderView.title;
}

- (void)setReorderDelegate:(id<ReorderDelegate>)reorderDelegate{
    _reorderView.reorderDelegate = reorderDelegate;
}

- (id<ReorderDelegate>)delegate{
    return _reorderView.reorderDelegate;
}

- (CGRect)reorderRect{
    return CGRectMake(118, 0, 150, 44);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        
        _oldState = UITableViewCellStateDefaultMask;
               
        CGRect reorderRect = [self reorderRect];
        reorderRect.origin.x += 32; //left inset of the tableview is 32px when the cell is in editmode
        _reorderView = [[AAReorderContentView alloc] initWithFrame:reorderRect];  
        [self.contentView addSubview:_reorderView];
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Overridden Methods

- (void)layoutSubviews{
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(10, 0, 100, CGRectGetHeight(self.contentView.frame));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    [_reorderView setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    
    [_reorderView setHighlighted:highlighted animated:animated];
}

- (void)highlightedDragOver:(BOOL)highlight animated:(BOOL)animated{
    [_reorderView highlightDragOver:highlight animated:animated];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    
    [_reorderView setEditing:editing animated:animated];
    
    if (editing) {
        CGRect frame = _reorderView.frame;
        frame.origin.x = [self reorderRect].origin.x; // FUCKIN TABLEVIEW ANIMATES 32PX
        
        [UIView animateWithDuration:0.3 animations:^{
            _reorderView.frame = frame; 
        }];
    } else {
        CGRect frame = _reorderView.frame;
        frame.origin.x = [self reorderRect].origin.x + 32;
        
        [UIView animateWithDuration:0.3 animations:^{
            _reorderView.frame = frame; 
        }];
    }
}

- (void)willTransitionToState:(UITableViewCellStateMask)state{
    [super willTransitionToState:state];
    
    if (_oldState == (UITableViewCellStateShowingEditControlMask | UITableViewCellStateShowingDeleteConfirmationMask) && state == UITableViewCellStateShowingEditControlMask) {
        [UIView animateWithDuration:0.3 animations:^{
            _reorderView.alpha = 1.0; 
        }];
    } else if (_oldState == UITableViewCellStateShowingEditControlMask && state == (UITableViewCellStateShowingEditControlMask | UITableViewCellStateShowingDeleteConfirmationMask)){
        [UIView animateWithDuration:0.3 animations:^{
            _reorderView.alpha = 0.0; 
        }];
    }
    
    _oldState = state;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Memory Management

- (void)prepareForReuse {
	[super prepareForReuse];	
}

@end
