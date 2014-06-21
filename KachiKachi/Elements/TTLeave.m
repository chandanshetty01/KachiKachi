//
//  TTLeave.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "TTLeave.h"

@implementation TTLeave

-(void)showAnimation:(completionBlk)completionBlk
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGRect frame = self.frame;
                         frame.origin.y = 1000;
                         self.frame = frame;
                     } completion:^(BOOL finished) {
                         completionBlk(finished);
                     }];
}

@end
