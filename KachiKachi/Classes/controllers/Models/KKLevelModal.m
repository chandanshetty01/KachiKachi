//
//  KKLevelModel.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "KKLevelModal.h"
#import "KKItemModal.h"

@implementation KKLevelModal

- (instancetype)initWithDictionary:(NSDictionary*)data
{
    self = [super init];
    if (self) {
        self.baskets = [data objectForKey:@"baskets"];
        self.backgroundImage = [data objectForKey:@"background"];
        self.life = [[data objectForKey:@"life"] intValue];
        self.items = [NSMutableArray array];
        [[data objectForKey:@"elements"] enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL *stop) {
            KKItemModal *item = [[KKItemModal alloc] initWithDictionary:obj];
            if(item)
                [self.items addObject:item];
        }];
    }
    return self;
}

-(NSMutableDictionary*)savedDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *elements = [NSMutableArray array];
    [self.items enumerateObjectsUsingBlock:^(KKItemModal *obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *itemDict = [obj savedDictionary];
        [elements addObject:itemDict];
    }];
    [dict setObject:elements forKey:@"elements"];
    if(self.baskets)
        [dict setObject:self.baskets forKey:@"baskets"];
    if(self.backgroundImage)
        [dict setObject:self.backgroundImage forKey:@"background"];
    [dict setObject:[NSString stringWithFormat:@"%d",self.life] forKey:@"life"];
    return dict;
}

@end