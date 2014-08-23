//
//  TTMagicStick.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "TTMagicStick.h"

@implementation TTMagicStick

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage *image = [UIImage imageNamed:@"magicStick"];
        self.magicStick = [[UIImageView alloc] initWithFrame:CGRectMake(250, 100, image.size.width, image.size.height)];
        self.magicStick.image = image;
        [self addSubview:self.magicStick];
    }
    return self;
}

-(void)startAnimation
{
    CGRect boundingRect = CGRectMake(0,0, 300, 300);
    
    CAKeyframeAnimation *orbit = [CAKeyframeAnimation animation];
    orbit.keyPath = @"position";
    orbit.path = CFAutorelease(CGPathCreateWithEllipseInRect(boundingRect, NULL));
    orbit.duration = 4;
    orbit.additive = YES;
    orbit.repeatCount = HUGE_VALF;
    orbit.calculationMode = kCAAnimationPaced;
    orbit.rotationMode = kCAAnimationRotateAuto;
    [self.magicStick.layer addAnimation:orbit forKey:@"orbit"];
}

-(void)stopAnimation
{
    [self.layer removeAllAnimations];
    [self.magicStick.layer removeAllAnimations];
}

- (void)dealloc
{
    
}

@end
