//
//  PASPageControlView.m
//  Passions
//
//  Created by Simon Tännler on 11/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASPageControlView.h"

@implementation PASPageControlView

#pragma mark - Init

- (void)awakeFromNib
{
	[self addTarget:self
			 action:@selector(handleValueChanged:)
   forControlEvents:UIControlEventValueChanged];
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