//
//  TTMagicStick.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTMagicStick : UIImageView
{
    
}
@property(nonatomic,strong) UIImageView *magicStick;

-(void)updateCount:(NSInteger)count;
-(void)startAnimation;
-(void)stopAnimation;
@end
