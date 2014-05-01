//
//  Utility.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

+(BOOL)isPolygonIntersected:(NSArray*)polygonA andPolygon:(NSArray*)polygonB;
+(BOOL)isLineCollided:(CGPoint)A1 secondPoint:(CGPoint)A2 thirdPoint:(CGPoint)B1 fourthPoint:(CGPoint)B2
               andOut:(double*) outPoint;
+(double)getPerpDot:(CGPoint)a secondPoint:(CGPoint)b;

@end
