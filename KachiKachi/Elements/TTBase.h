//
//  TTBase.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTBase : UIView
{
    
}

@property(nonatomic,strong) NSMutableArray *touchPoints;
@property(nonatomic,assign) CGFloat angle;
@property(nonatomic,strong) NSString *imagePath;
@property(nonatomic,assign) BOOL canSaveTouchPoints;
@property(nonatomic,strong) UIImage *image;
@property(nonatomic,assign) CGRect animationEndFrame;
@property(nonatomic,assign) CGFloat animationAngle;
@property(nonatomic,assign) CGFloat animationScale;
@property(nonatomic,assign) BOOL hasEndAnimation;

- (id)initWithData : (NSDictionary*)inData;

- (void)handleTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)handleTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)handleTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)handleTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

- (BOOL)canHandleTouch:(CGPoint)touchPoint;
- (NSDictionary*)saveDictionary;

@end
