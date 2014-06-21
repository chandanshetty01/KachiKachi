//
//  TTApple.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "TTApple.h"

@implementation TTApple

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
    [UIView animateWithDuration:0.4
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.frame = self.animationEndFrame;
                     } completion:^(BOOL finished) {
                         if(finished)
                         {
                             [UIView animateWithDuration:0.3
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^{
                                                  CGRect frame = CGRectInset(self.frame,25,25);
                                                  self.frame = frame;
                                                  self.alpha = 0;
                                              } completion:^(BOOL finished) {
                                                  completionBlk(YES);
                                              }];
                         }
                         
                     }];
}


@end
