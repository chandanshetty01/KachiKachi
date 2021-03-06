//
//  TTBalloon.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "TTBalloon.h"

@implementation TTBalloon

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
    CGFloat animationInterval = 0.2f;
    if(IS_IPAD){
        animationInterval = 0.4f;
    }
    [UIView animateWithDuration:animationInterval
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.frame;
                         frame.origin.y = -500;
                         self.frame = frame;
                     } completion:^(BOOL finished) {
                         completionBlk(finished);
                     }];
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
