//
//  TTBase.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "TTBase.h"

@interface  TTBase()

@property(nonatomic,assign) BOOL dragging;
@property(nonatomic,assign) CGFloat oldX;
@property(nonatomic,assign) CGFloat oldY;

@end

@implementation TTBase

-(id)initWithData : (NSDictionary*)inData
{
    self = [super init];
    if(self){
        
        self.imagePath = [inData objectForKey:@"image"];
        _image = [UIImage imageNamed:_imagePath];
        CGRect frame = CGRectFromString([inData objectForKey:@"frame"]);
        if(frame.size.width == -1 || frame.size.height == -1)
        {
            frame.size = _image.size;
        }
        self.frame = frame;
        
        self.touchPoints = [inData objectForKey:@"touchPoints"];
        if(self.touchPoints == nil){
            self.touchPoints = [NSMutableArray array];
        }
        
        self.angle = [[inData objectForKey:@"angle"] floatValue];
        
        NSDictionary *animation = [inData objectForKey:@"animation"];
        if(animation){
            _animationEndFrame = CGRectFromString([animation objectForKey:@"frame"]);
            _animationAngle = [[animation objectForKey:@"scale"] floatValue];
            _animationScale = [[animation objectForKey:@"rotateAngle"] floatValue];
            _hasEndAnimation = YES;
        }
        
#ifdef DEVELOPMENT_MODE
        self.backgroundColor = [UIColor grayColor];
#else
        self.backgroundColor = [UIColor clearColor];
#endif
    }
    return self;
}

-(NSDictionary*)saveDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:_imagePath forKey:@"image"];
    [dict setObject:NSStringFromClass([self class]) forKey:@"class"];
    [dict setObject:NSStringFromCGRect(self.frame) forKey:@"frame"];
    [dict setObject:self.touchPoints forKey:@"touchPoints"];
    return dict;
}

-(BOOL)canHandleTouch:(CGPoint)touchPoint
{
    CGMutablePathRef path = CGPathCreateMutable();
    int i = 0;

#ifdef DEVELOPMENT_MODE
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
        return YES;
    return NO;
    
#endif
    
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
    
    if(CGPathContainsPoint(path, nil, touchPoint, NO))
        return YES;
    return NO;
}

- (void)handleTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    _dragging = YES;
    _oldX = touchLocation.x;
    _oldY = touchLocation.y;
}

- (void)handleTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (_dragging) {
        CGRect frame = self.frame;
        frame.origin.x = self.frame.origin.x + touchLocation.x - _oldX;
        frame.origin.y =  self.frame.origin.y + touchLocation.y - _oldY;
        //self.transform = CGAffineTransformIdentity;
        self.frame = frame;
        //self.transform = CGAffineTransformIdentity;

    }
}

-(void)handleTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    _dragging = NO;
}

- (void)handleTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if(_canSaveTouchPoints){
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint touchLocation = [touch locationInView:self];
        [self.touchPoints addObject:NSStringFromCGPoint(touchLocation)];
    }

#ifdef DEVELOPMENT_MODE
    [self setNeedsDisplay];
#endif
    _dragging = NO;
}

- (void)drawRect:(CGRect)rect {
    
    [_image drawInRect:rect];
    
#ifdef DEVELOPMENT_MODE
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    
    // Draw them with a 2.0 stroke width so they are a bit more visible.
    CGContextSetLineWidth(context, 2.0);
    
    int count = [_touchPoints count];
    for (int i = 0 ; i < count; i++) {
        CGPoint cPoint = CGPointFromString([_touchPoints objectAtIndex:i]);
        if(i == 0)
            CGContextMoveToPoint(context, cPoint.x,cPoint.y); //start at this point
        else
            CGContextAddLineToPoint(context, cPoint.x, cPoint.y); //draw to this point
    }
    CGContextClosePath(context);

    // and now draw the Path!
    CGContextStrokePath(context);
#endif
    [super drawRect:rect];
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

@end
