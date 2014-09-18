//
//  TTBase.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "TTBase.h"
#import "Utility.h"

@interface  TTBase()

@property(nonatomic,assign) BOOL dragging;
@property(nonatomic,assign) CGFloat oldX;
@property(nonatomic,assign) CGFloat oldY;
@property(nonatomic,assign) BOOL selected;

@end

@implementation TTBase

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selected = NO;
    }
    return self;
}

- (void)initWithModal:(KKItemModal*)itemModal
{
    self.itemModal = itemModal;
    
    self.imagePath = itemModal.imagePath;
    _image = [UIImage imageNamed:_imagePath];
    CGRect frame = itemModal.frame;
    if(frame.size.width == -1 || frame.size.height == -1)
    {
        frame.size = _image.size;
    }
    self.frame = frame;
    
    self.touchPoints = [itemModal.touchPoints mutableCopy];
    if(self.touchPoints == nil){
        self.touchPoints = [NSMutableArray array];
    }
    [self createPathRef];
    
    self.angle = itemModal.angle;
    
    NSDictionary *animation = itemModal.animation;
    if(animation){
        _animationEndFrame = CGRectFromString([animation objectForKey:@"frame"]);
        _animationAngle = [[animation objectForKey:@"scale"] floatValue];
        _animationScale = [[animation objectForKey:@"rotateAngle"] floatValue];
        _hasEndAnimation = YES;
    }
    
    self.isPicked = itemModal.isPicked;

#ifdef DEVELOPMENT_MODE
    self.backgroundColor = [UIColor grayColor];
#else
    self.backgroundColor = [UIColor clearColor];
#endif
}

-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    [self setNeedsDisplay];
}

-(NSMutableDictionary*)saveDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_imagePath forKey:@"image"];
    [dict setObject:NSStringFromClass([self class]) forKey:@"class"];
    [dict setObject:NSStringFromCGRect(self.frame) forKey:@"frame"];
    [dict setObject:self.touchPoints forKey:@"touchPoints"];
    [dict setObject:[NSNumber numberWithBool:self.isPicked] forKey:@"isPicked"];
    
    NSMutableDictionary *animation = [NSMutableDictionary dictionary];
    [animation setObject:NSStringFromCGRect(_animationEndFrame) forKey:@"frame"];
    [animation setObject:[NSString stringWithFormat:@"%f",_animationAngle] forKey:@"rotateAngle"];
    [animation setObject:[NSString stringWithFormat:@"%f",_animationScale] forKey:@"scale"];
    [dict setObject:animation forKey:@"animation"];

    return dict;
}

-(void)createPathRef
{
    CGMutablePathRef path = CGPathCreateMutable();
    int i = 0;
    for(NSString* point in _touchPoints){
        CGPoint cPoint = CGPointFromString(point);
        cPoint.x = cPoint.x+self.frame.origin.x;
        cPoint.y = cPoint.y+self.frame.origin.y;
        
        if(i == 0)
            CGPathMoveToPoint(path, NULL, cPoint.x, cPoint.y);
        else
        {
            CGPathAddLineToPoint(path, NULL, cPoint.x, cPoint.y);
        }
        i++;
    }
    CGPathCloseSubpath(path);
    self.objectPath = path;
}


-(BOOL)canHandleTouch:(CGPoint)center radius:(CGFloat)radius
{
#ifdef DEVELOPMENT_MODE
    return [self canHandleTouch:center];
#endif
    BOOL status = NO;
    if(!self.isPicked && self.userInteractionEnabled){
        NSMutableArray *polygonA = [NSMutableArray array];
        for(NSString *point in self.touchPoints){
            CGPoint cPoint = CGPointFromString(point);
            cPoint.x = cPoint.x+self.frame.origin.x;
            cPoint.y = cPoint.y+self.frame.origin.y;
            [polygonA addObject:NSStringFromCGPoint(cPoint)];
        }
        
        CGPoint point1 = CGPointMake(center.x-radius/2, center.y-radius/2);
        CGPoint point2 = CGPointMake(point1.x+radius, point1.y);
        CGPoint point3 = CGPointMake(point1.x+ radius, point1.y+radius);
        CGPoint point4 = CGPointMake(point1.x, point1.y+radius);
        
        NSMutableArray *polygonB = [NSMutableArray array];
        [polygonB  addObject:NSStringFromCGPoint(point1)];
        [polygonB  addObject:NSStringFromCGPoint(point2)];
        [polygonB  addObject:NSStringFromCGPoint(point3)];
        [polygonB  addObject:NSStringFromCGPoint(point4)];
        [polygonB  addObject:NSStringFromCGPoint(point1)];
        
        BOOL isIntersected = [Utility pathContainsPolygon:self.objectPath polygon:polygonB];
        if(isIntersected){
            status = YES;
        }
        
        if(!status){
            status = [Utility isPolygonIntersected:polygonA andPolygon:polygonB ];
        }
    }
    return status;
}

-(BOOL)canHandleTouch:(CGPoint)touchPoint
{
#ifdef DEVELOPMENT_MODE
    CGMutablePathRef path = CGPathCreateMutable();
    int i = 0;
    NSMutableArray *touchArry = [NSMutableArray array];
    [touchArry addObject:NSStringFromCGPoint(CGPointMake(0, 0))];
    [touchArry addObject:NSStringFromCGPoint(CGPointMake(self.frame.size.width,0))];
    [touchArry addObject:NSStringFromCGPoint(CGPointMake(self.frame.size.width,self.frame.size.height))];
    [touchArry addObject:NSStringFromCGPoint(CGPointMake(0, self.frame.size.height))];
    [touchArry addObject:NSStringFromCGPoint(CGPointMake(0,0))];
    
    for(NSString* point in touchArry){
        CGPoint cPoint = CGPointFromString(point);
        cPoint.x = cPoint.x+self.frame.origin.x;
        cPoint.y = cPoint.y+self.frame.origin.y;
        
        if(i == 0)
            CGPathMoveToPoint(path, NULL, cPoint.x, cPoint.y);
        else
        {
            CGPathAddLineToPoint(path, NULL, cPoint.x, cPoint.y);
        }
        i++;
    }
    CGPathCloseSubpath(path);
    
    if(CGPathContainsPoint(path, nil, touchPoint, NO))
    {
        CGPathRelease(path);
        return YES;
    }
    CGPathRelease(path);
    return NO;
#endif
    
    if(!self.isPicked && self.userInteractionEnabled && CGPathContainsPoint(self.objectPath, nil, touchPoint, NO))
        return YES;
    return NO;
}

- (void)handleTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.selected = YES;
#ifdef DEVELOPMENT_MODE
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    _dragging = YES;
    _oldX = touchLocation.x;
    _oldY = touchLocation.y;
#endif
}

- (void)handleTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (_dragging) {
        CGRect frame = self.frame;
        frame.origin.x = self.frame.origin.x + touchLocation.x - _oldX;
        frame.origin.y =  self.frame.origin.y + touchLocation.y - _oldY;
        self.frame = frame;
    }
    self.selected = YES;
}

-(void)handleTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.selected = NO;
    _dragging = NO;
}

- (void)handleTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_canSaveTouchPoints){
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint touchLocation = [touch locationInView:self];
        [self.touchPoints addObject:NSStringFromCGPoint(touchLocation)];
    }

#ifdef DEVELOPMENT_MODE
    [self setNeedsDisplay];
#endif
    _dragging = NO;
    self.selected = NO;
}

-(void)drawPolygon:(NSMutableArray*)array
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0);
    
    int count = (int)[array count];
    for (int i = 0 ; i < count; i++) {
        CGPoint cPoint = CGPointFromString([array objectAtIndex:i]);
        if(i == 0)
            CGContextMoveToPoint(context, cPoint.x,cPoint.y); //start at this point
        else
            CGContextAddLineToPoint(context, cPoint.x, cPoint.y); //draw to this point
    }
    //CGContextFillPath(context);
    CGContextClosePath(context);
    
    // and now draw the Path!
    CGContextStrokePath(context);
}

- (void)drawRect:(CGRect)rect
{    
    if(self.selected){
        [_image drawInRect:rect blendMode:kCGBlendModeColor alpha:0.7f];
    }
    else{
        [_image drawInRect:rect];
    }
    
#ifdef DEVELOPMENT_MODE
    [self drawPolygon:self.touchPoints];
#endif

    [super drawRect:rect];
}

- (void)setPickedObjectPosition
{
    self.alpha = 0;
}
 
-(void)showAnimation:(completionBlk)completionBlk
{
    CGFloat animationInterval = 0.3f;
    if(IS_IPAD){
        animationInterval = 0.5f;
    }
    [UIView animateWithDuration:animationInterval animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        completionBlk(finished);
    }];
}

-(void)shakeAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.removedOnCompletion = YES;
    animation.keyPath = @"position.x";
    animation.values = @[ @0, @10, @-10, @10, @0 ];
    animation.keyTimes = @[ @0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1 ];
    animation.duration = 0.4;
    animation.additive = YES;
    [self.layer addAnimation:animation forKey:@"savingAnimation"];
}

/*
 - (BOOL)canHandleTouch:(CGPoint)touchPoint
 {
 NSMutableArray *touchArry = [NSMutableArray array];
 for(NSString* point in _touchPoints){
 CGPoint cPoint = CGPointFromString(point);
 cPoint.x = cPoint.x+self.frame.origin.x;
 cPoint.y = cPoint.y+self.frame.origin.y;
 // CGPoint rotatedPoint = [self rotatePoint:cPoint andAngle:self.angle];
 [touchArry addObject:NSStringFromCGPoint(cPoint)];
 }
 
 #ifdef DEVELOPMENT_MODE
 if(1){
 touchArry = [NSMutableArray array];
 [touchArry addObject:NSStringFromCGPoint(CGPointMake(self.frame.origin.x, self.frame.origin.y))];
 [touchArry addObject:NSStringFromCGPoint(CGPointMake(self.frame.origin.x+self.frame.size.width, self.frame.origin.y))];
 [touchArry addObject:NSStringFromCGPoint(CGPointMake(self.frame.origin.x+self.frame.size.width, self.frame.origin.y+self.frame.size.height))];
 [touchArry addObject:NSStringFromCGPoint(CGPointMake(self.frame.origin.x, self.frame.origin.y+self.frame.size.width))];
 [touchArry addObject:NSStringFromCGPoint(CGPointMake(self.frame.origin.x, self.frame.origin.y))];
 }
 #else
 #endif
 
 if([self isPointInsidePolyGon:touchPoint andPoints:touchArry])
 return YES;
 
 return NO;
 }
 */

- (void)dealloc
{
    [self.layer removeAllAnimations];
    CGPathRelease(_objectPath);
}

@end
