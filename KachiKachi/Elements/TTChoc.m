//
//  TTChoc.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "TTChoc.h"

@implementation TTChoc

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
    self.userInteractionEnabled = NO;
    self.completionBlk = completionBlk;
    
    // Set up path movement
    CGPoint viewOrigin = self.frame.origin;
    CGPoint endPoint = self.animationEndFrame.origin;
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.removedOnCompletion = YES;
    
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, viewOrigin.x, viewOrigin.y);
    CGPathAddCurveToPoint(curvedPath, NULL,viewOrigin.x, viewOrigin.y,0,0,endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.removedOnCompletion = YES;
    [group setAnimations:[NSArray arrayWithObjects:pathAnimation, nil]];
    group.duration = 0.5f;
    group.delegate = self;
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
