//
//  PlaceholderReorderView.m
//  TrainingDay
//
//  Created by Georg Kitz on 12/27/11.
//  Copyright 2011 Spartan Technologies UG. All rights reserved.
//

#import "AAPlaceholderReorderView.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AAPlaceholderReorderView

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Setter/Getter

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

@synthesize text = _text;
@synthesize color = _color;

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
        self.backgroundColor = [UIColor clearColor];
        self.color = [UIColor colorWithRed:204/255. green:151/255. blue:90/255. alpha:0.4];
    }
    return self;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Methods

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
    [self.color set];
    [self.text drawInRect:CGRectMake(0, 11, CGRectGetWidth(self.frame) - 34, 22) withFont:[UIFont systemFontOfSize:17] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
}

@end
