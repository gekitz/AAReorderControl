//
//  PlaceholderReorderView.h
//  TrainingDay
//
//  Created by Georg Kitz on 12/27/11.
//  Copyright 2011 Spartan Technologies UG. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*!
 @class       PlaceholderReorderView
 @abstract  
 @discussion
 */
@interface AAPlaceholderReorderView : UIView {
    NSString *_text;
    UIColor *_color;
}

@property (nonatomic, strong) NSString *text; 
@property (nonatomic, strong) UIColor *color;

@end
