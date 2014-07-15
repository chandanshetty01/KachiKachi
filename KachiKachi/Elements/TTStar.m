//
//  TTStar.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "TTStar.h"

@implementation TTStar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
-(void)showAnimation:(completionBlk)completionBlk
{
    [UIView animateWithDuration:.2f animations:^{
        self.alpha = 0.2;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.1f animations:^{
            self.alpha = 0.8;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.1f animations:^{
                self.alpha = 0.4;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:.1f animations:^{
                    self.alpha = 0.8;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:.2f animations:^{
                        self.alpha = 0;
                    } completion:^(BOOL finished) {
                        completionBlk(finished);
                    }];
                }];
            }];
        }];
    }];
}
 */

@end
