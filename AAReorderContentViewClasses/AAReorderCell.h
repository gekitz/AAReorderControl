//
//  DayCell.h
//  TrainingDay
//
//  Created by Georg Kitz on 11/7/11.
//  Copyright 2011 Spartan Technologies UG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AAReorderContentView.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*!
 @class       DayCell
 @abstract  
 @discussion
 */
 
@interface AAReorderCell : UITableViewCell {
    
    //Reordering
    AAReorderContentView *_reorderView;
    UITableViewCellStateMask _oldState;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) AAReorderContentView *reorderingView;
@property (nonatomic, weak) id<ReorderDelegate> reorderDelegate;
@property (nonatomic, readonly) CGRect reorderRect;

- (void)highlightedDragOver:(BOOL)highlight animated:(BOOL)animated;

@end
