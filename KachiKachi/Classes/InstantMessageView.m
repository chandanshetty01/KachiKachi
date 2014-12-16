//
//  InstantMessageView.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "InstantMessageView.h"

@interface InstantMessageView()
@property(nonatomic,assign)NSInteger duration;
@property(nonatomic,strong)NSString *message;
@property(nonatomic,strong)UILabel *label;
@end

@implementation InstantMessageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        self.label.font = [UIFont boldSystemFontOfSize:10];
        self.backgroundColor = [UIColor clearColor];
        self.label.textColor = [UIColor whiteColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 2;
        self.label.backgroundColor = [UIColor clearColor];
        [self addSubview:self.label];
        self.userInteractionEnabled = NO;
    }
    return self;
}

-(void)showMessage:(NSString*)message
          duration:(NSInteger)duration
             color:(UIColor*)color
              font:(UIFont*)font
        completion:(completionBlk)blk
{
    self.label.text = message;
    self.label.textColor = color;
    self.label.font = font;
    CGRect frame = self.frame;
    frame.origin.y -= 50;
    CGFloat animationInterval = duration;
    [UIView animateWithDuration:animationInterval
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.frame = frame;
                         self.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         if(finished){
                             [self removeFromSuperview];
                             if(blk){
                                 blk(YES);
                             }
                         }
                     }];
}

- (void)dealloc
{
    NSLog(@"");
}

@end
