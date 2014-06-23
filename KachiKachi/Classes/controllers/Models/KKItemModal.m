//
//  KKItemModel.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "KKItemModal.h"

@implementation KKItemModal

- (instancetype)initWithDictionary:(NSDictionary*)data
{
    self = [super init];
    if (self) {
        
        self.className = [data objectForKey:@"class"];
        self.frame = CGRectFromString([data objectForKey:@"frame"]);
        self.imagePath = [data objectForKey:@"image"];
        self.touchPoints = [data objectForKey:@"touchPoints"];
        self.angle = [[data objectForKey:@"angle"] floatValue];
        self.animation = [data objectForKey:@"animation"];
        self.isPicked = [[data objectForKey:@"isPicked"] boolValue];
    }
    return self;
}

-(NSMutableDictionary*)savedDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.className forKey:@"class"];
    [dict setObject:NSStringFromCGRect(self.frame) forKey:@"frame"];
    [dict setObject:self.imagePath forKey:@"image"];
    [dict setObject:self.touchPoints forKey:@"touchPoints"];
    [dict setObject:[NSString stringWithFormat:@"%f",self.angle] forKey:@"angle"];
    [dict setObject:[NSNumber numberWithBool:self.isPicked] forKey:@"isPicked"];
    if(self.animation)
        [dict setObject:self.animation forKey:@"animation"];
    return dict;
}

@end
