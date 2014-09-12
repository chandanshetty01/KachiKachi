//
//  TTDvd.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "TTDvd.h"

@implementation TTDvd

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
    
    if(IS_IPAD){
            CGPathAddCurveToPoint(curvedPath, NULL,viewOrigin.x, viewOrigin.y,1024,0,endPoint.x, endPoint.y);
    }
    else{
        CGPathAddCurveToPoint(curvedPath, NULL,viewOrigin.x, viewOrigin.y,0,0,endPoint.x, endPoint.y);
    }

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

@end
