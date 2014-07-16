//
//  TTDisc.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "TTDisc.h"

@implementation TTDisc

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIBezierPath *)bezierPath
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(0.0, 0.0)];
    [path addLineToPoint:CGPointMake(200.0, 200.0)];
    
    return path;
}

/*
-(void)showAnimation:(completionBlk)completionBlk
{
    [UIView animateWithDuration:0.6
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.frame = self.animationEndFrame;
                     } completion:^(BOOL finished) {
                         completionBlk(false);
                     }];
}
*/

-(void)showAnimation:(completionBlk)completionBlk
{
    self.userInteractionEnabled = NO;
    self.completionBlk = completionBlk;
    
    // Set up path movement
    CGPoint viewOrigin = self.frame.origin;
    CGPoint endPoint = self.animationEndFrame.origin;
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.removedOnCompletion = YES;
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, viewOrigin.x, viewOrigin.y);
    CGPathAddCurveToPoint(curvedPath, NULL,viewOrigin.x, viewOrigin.y,0,-20,endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.removedOnCompletion = YES;
    [group setAnimations:[NSArray arrayWithObjects:pathAnimation, nil]];
    group.duration = 0.5f;
    group.delegate = self;
    self.layer.position = endPoint;
    [self.layer addAnimation:group forKey:@"savingAnimation"];
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    [self.layer removeAllAnimations];
    if(flag && self.completionBlk){
        self.frame = self.animationEndFrame;
        self.completionBlk(NO);
        self.completionBlk = nil;
    }
}

- (void)setPickedObjectPosition
{
    self.frame = self.animationEndFrame;
}


@end
