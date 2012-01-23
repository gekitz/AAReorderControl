//
//  DayCell.m
//  TrainingDay
//
//  Created by Georg Kitz on 11/7/11.
//  Copyright 2011 Spartan Technologies UG. All rights reserved.
//

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
                
        _reorderView = [[AAReorderContentView alloc] initWithFrame:CGRectMake(150, 0, 150, 44)]; // 60 to 
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
        frame.origin.x = 118; // FUCKIN TABLEVIEW ANIMATES 32PX
        
        [UIView animateWithDuration:0.3 animations:^{
            _reorderView.frame = frame; 
        }];
    } else {
        CGRect frame = _reorderView.frame;
        frame.origin.x = 150;
        
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
