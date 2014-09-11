//
//  PASPageControlView.m
//  Passions
//
//  Created by Simon Tännler on 11/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASPageControlView.h"

@implementation PASPageControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.currentPage = [self.delegate presentationIndexForPageControlView:self];
		self.numberOfPages = [self.delegate presentationCountForPageControlView:self];
		
		[self addTarget:self
				 action:@selector(handleValueChanged:)
	   forControlEvents:UIControlEventValueChanged];
		
		
    }
    return self;
}

- (void)handleValueChanged:(id)bla
{
	NSLog(@"handleValueChanged %@", bla);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
