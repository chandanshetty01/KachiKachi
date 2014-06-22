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
    }
    return self;
}

@end
