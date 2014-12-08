//
//  Utility.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKStoreManager.h"

@interface Utility : NSObject

+(id)sharedManager;

+(BOOL)isPolygonIntersected:(NSArray*)polygonA andPolygon:(NSArray*)polygonB;
+(BOOL)isLineCollided:(CGPoint)A1 secondPoint:(CGPoint)A2 thirdPoint:(CGPoint)B1 fourthPoint:(CGPoint)B2
               andOut:(double*) outPoint;
+(double)getPerpDot:(CGPoint)a secondPoint:(CGPoint)b;
+(BOOL)pathContainsPolygon:(CGPathRef)path polygon:(NSMutableArray*)inPolygon;

-(SKProduct*)productWithID:(NSString*)inID;

+(NSString*)documentsDirectory;
+(NSInteger)saveData:(NSDictionary*)dictionary fileName:(NSString*)fileName;
+(NSDictionary*)loadData:(NSString*)fileName;
@end
