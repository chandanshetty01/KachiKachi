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
        UIImage *image = [UIImage imageNamed:_imagePath];
        CGRect frame = CGRectFromString([inData objectForKey:@"frame"]);
        if(frame.size.width == -1 || frame.size.height == -1)
        {
            frame.size = image.size;
        }
        self.frame = frame;
        
        self.touchPoints = [inData objectForKey:@"touchPoints"];
        if(self.touchPoints == nil){
            self.touchPoints = [NSMutableArray array];
            /*
            NSMutableArray *touchArry = [NSMutableArray array];
            [touchArry addObject:NSStringFromCGPoint(CGPointMake(self.frame.origin.x, self.frame.origin.y))];
            [touchArry addObject:NSStringFromCGPoint(CGPointMake(self.frame.origin.x+self.frame.size.width, self.frame.origin.y))];
            [touchArry addObject:NSStringFromCGPoint(CGPointMake(self.frame.origin.x+self.frame.size.width, self.frame.origin.y+self.frame.size.height))];
            [touchArry addObject:NSStringFromCGPoint(CGPointMake(self.frame.origin.x, self.frame.origin.y+self.frame.size.width))];
            [touchArry addObject:NSStringFromCGPoint(CGPointMake(self.frame.origin.x, self.frame.origin.y))];
            self.touchPoints = touchArry;
             */
        }
        
        self.angle = [[inData objectForKey:@"angle"] floatValue];
        
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        imageview.image = image;
        //imageview.transform = CGAffineTransformMakeRotation(M_PI * self.angle / 180);
        [self addSubview:imageview];
        
#ifdef DEVELOPMENT_MODE
        self.backgroundColor = [UIColor clearColor];
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

/*
POINT rotate_point(float cx,float cy,float angle,POINT p)
{
    float s = sin(angle);
    float c = cos(angle);
    
    // translate point back to origin:
    p.x -= cx;
    p.y -= cy;
    
    // rotate point
    float xnew = p.x * c - p.y * s;
    float ynew = p.x * s + p.y * c;
    
    // translate point back:
    p.x = xnew + cx;
    p.y = ynew + cy;
}
*/

-(CGPoint)rotatePoint:(CGPoint)inPoint andAngle:(CGFloat)angle
{
    self.angle = 90;
    inPoint = CGPointMake(100, 100);
    CGPoint rotatedPoint;
    rotatedPoint.x = (inPoint.x * cos(M_PI * self.angle / 180)) - (inPoint.y * sin(M_PI * self.angle / 180));
    rotatedPoint.y =(inPoint.y * cos(M_PI * self.angle / 180)) + (inPoint.x * sin(M_PI * self.angle / 180));
    return rotatedPoint;
}

// wn_PnPoly(): winding number test for a point in a polygon
//      Input:   P = a point,
//               V[] = vertex points of a polygon V[n+1] with V[n]=V[0]
//      Return:  wn = the winding number (=0 only if P is outside V[])
//http://www.softsurfer.com/Archive/algorithm_0103/algorithm_0103.htm

// isLeft(): tests if a point is Left|On|Right of an infinite line.
//    Input:  three points P0, P1, and P2
//    Return: >0 for P2 left of the line through P0 and P1
//            =0 for P2 on the line
//            <0 for P2 right of the line
//    See: the January 2001 Algorithm "Area of 2D and 3D Triangles and Polygons"

-(NSInteger) isLeft:(CGPoint)P0 andPoint1:(CGPoint)P1 andPoint2:(CGPoint)P2
{
    return ( (P1.x - P0.x) * (P2.y - P0.y)
            - (P2.x - P0.x) * (P1.y - P0.y) );
}

-(int)isPointInsidePolyGon:(CGPoint)P andPoints:(NSArray *)V
{
    int  wn = 0;    // the winding number counter
    
    
    for(int i = 0 ; i < [V count]-1; i++)
    {
        CGPoint cPoint = CGPointFromString(V[i]);

        if (cPoint.y <= P.y) {         // start y <= P.y
            CGPoint nPoint = CGPointFromString(V[i+1]);
            if (nPoint.y > P.y)      // an upward crossing
                if([self isLeft:cPoint andPoint1:nPoint andPoint2:P] > 0)
                    ++wn;            // have a valid up intersect        }
        }
        else {
            CGPoint nPoint = CGPointFromString(V[i+1]);
            // start y > P.y (no test needed)
            if (nPoint.y <= P.y)     // a downward crossing
                if([self isLeft:cPoint andPoint1:nPoint andPoint2:P] < 0)
                    --wn;            // have a valid down intersect
        }
    }
    
    return wn;
}

/*
-(BOOL)canHandleTouch:(CGPoint)touchPoint
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
    
    CGAffineTransform transform= CGAffineTransformMakeRotation(M_PI * self.angle / 180);
    if(CGPathContainsPoint(path, nil, touchPoint, NO))
        return YES;
    return NO;
}
*/
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
    
    if(_canSaveTouchPoints && [self.touchPoints count] < 4){
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint touchLocation = [touch locationInView:self];
        [self.touchPoints addObject:NSStringFromCGPoint(touchLocation)];
        if([self.touchPoints count] == 4)
            [self.touchPoints addObject:[self.touchPoints objectAtIndex:0]];
    }

    _dragging = NO;
}

@end
