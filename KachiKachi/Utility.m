//
//  Utility.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (id) sharedManager
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

+(double)getDot:(CGPoint)a secondPoint:(CGPoint)b
{
    return (a.x*b.x) + (a.y*b.y);
}

+(double)getPerpDot:(CGPoint)a secondPoint:(CGPoint)b
{
    return (a.y*b.x) - (a.x*b.y);
}

+(BOOL)isLineCollided:(CGPoint)A1 secondPoint:(CGPoint)A2 thirdPoint:(CGPoint)B1 fourthPoint:(CGPoint)B2
               andOut:(double*) outPoint
{
    CGPoint a = CGPointMake(A2.x-A1.x, A2.y-A1.y);
    CGPoint b = CGPointMake(B2.x-B1.x, B2.y-B1.y);
    
    
    double f = [self getPerpDot:a secondPoint:b];
    if(!f)      // lines are parallel
        return false;
    
    CGPoint c = CGPointMake(B2.x-A2.x, B2.y-A2.y);
    double aa = [self getPerpDot:a secondPoint:c];
    double bb = [self getPerpDot:b secondPoint:c];
    
    if(f < 0)
    {
        if(aa > 0)     return false;
        if(bb > 0)     return false;
        if(aa < f)     return false;
        if(bb < f)     return false;
    }
    else
    {
        if(aa < 0)     return false;
        if(bb < 0)     return false;
        if(aa > f)     return false;
        if(bb > f)     return false;
    }
    
    if(outPoint)
        *outPoint = 1.0 - (aa / f);
    return true;
}

+(BOOL)pathContainsPolygon:(CGPathRef)path polygon:(NSMutableArray*)inPolygon
{
    __block BOOL status = TRUE;
    [inPolygon enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *inPoint = (NSString*)obj;
        CGPoint touchPoint = CGPointFromString(inPoint);
        if(!CGPathContainsPoint(path, nil, touchPoint, NO)){
            *stop = YES;
            status = FALSE;
        }
    }];
    return status;
}

+(BOOL)isPolygonIntersected:(NSArray*)polygonA andPolygon:(NSArray*)polygonB
{
    for (int i = 0 ; i < [polygonA count]; i++) {
        CGPoint p1A = CGPointFromString([polygonA objectAtIndex:i]);
        CGPoint p1B;
        if(i+1 >= [polygonA count])
            p1B = CGPointFromString([polygonA objectAtIndex:0]);
        else
            p1B = CGPointFromString([polygonA objectAtIndex:i+1]);
        
        for (int j = 0 ; j < [polygonB count]; j++) {
            CGPoint p2A = CGPointFromString([polygonB objectAtIndex:j]);
            CGPoint p2B;
            if(j+1 >= [polygonB count])
                p2B = CGPointFromString([polygonB objectAtIndex:0]);
            else
                p2B = CGPointFromString([polygonB objectAtIndex:j+1]);
            
            double outPoint = 0;
            bool isColided  = [Utility isLineCollided:p1A secondPoint:p1B thirdPoint:p2A fourthPoint:p2B andOut:&outPoint];
            if(isColided)
                return YES;
        }
    }
    
    return NO;
}

-(SKProduct*)productWithID:(NSString*)inID
{
    __block SKProduct *product = nil;
    NSMutableArray *products = [MKStoreManager sharedManager].purchasableObjects;
    [products enumerateObjectsUsingBlock:^(SKProduct *obj, NSUInteger idx, BOOL *stop) {
        if([obj.productIdentifier isEqualToString:inID]){
            product = obj;
            *stop = YES;
        }
    }];
    return product;
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
 
 
 for(int i = 0 ; i < ([V count]-1 && [V count] > 0); i++)
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
 */
@end
