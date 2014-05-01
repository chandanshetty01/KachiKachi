//
//  Utility.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "Utility.h"

@implementation Utility

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

@end
