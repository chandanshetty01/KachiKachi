//
//  TTMagicStick.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "TTMagicStick.h"

@interface TTMagicStick()
@property(nonatomic,strong) UILabel* counterLabel;
@end

@implementation TTMagicStick

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage *image = [UIImage imageNamed:@"magicStick"];
        CGRect frame = CGRectMake(250, 100, image.size.width, image.size.height);
        if(!IS_IPAD){
            frame = CGRectMake(140, 0, image.size.width, image.size.height);
        }
        self.magicStick = [[UIImageView alloc] initWithFrame:frame];
        self.magicStick.image = image;
        [self addSubview:self.magicStick];
        ;
        CGSize size = CGSizeMake(40, 40);
        self.counterLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, image.size.height-size.height, size.width , size.height)];
        [self.counterLabel setFont:[UIFont boldSystemFontOfSize:30]];
        [self.counterLabel setTextColor:[UIColor colorWithRed:220/255.0f green:153/255.0f blue:35/255.0f alpha:1.0f]];
        [self.magicStick addSubview:self.counterLabel];
        [self updateCount:0];
    }
    return self;
}

-(void)updateCount:(NSInteger)count
{
    [self.counterLabel setText:[NSString stringWithFormat:@"%ld",(long)count]];
}

-(void)startAnimation
{
    CGRect boundingRect = CGRectMake(0,0, 300, 300);
    if(!IS_IPAD){
        boundingRect = CGRectMake(0,0, 150, 150);
    }
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
