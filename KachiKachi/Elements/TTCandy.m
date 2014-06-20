//
//  TTCandy.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "TTCandy.h"

@implementation TTCandy

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)showAnimation:(completionBlk)completionBlk
{
    [UIView animateWithDuration:0.8
                          delay:0.2
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.frame = self.animationEndFrame;
                     } completion:^(BOOL finished) {
                         completionBlk(NO);
                     }];
}

@end
