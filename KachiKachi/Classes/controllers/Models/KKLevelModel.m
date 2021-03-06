//
//  KKLevelModel.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "KKLevelModel.h"
#import "KKItemModal.h"

@implementation KKLevelModel

- (instancetype)initWithDictionary:(NSDictionary*)data
{
    self = [super init];
    if (self) {
        self.levelID = [[data objectForKey:@"ID"] intValue];
        
        NSNumber *stars = [data objectForKey:@"stars"];
        if(stars){
            self.noOfStars = [stars intValue];
        }
        else{
            self.noOfStars = -1;
        }
        
        self.menuIconImage = [data objectForKey:@"menuImage"];
        self.isLevelCompleted = [[data objectForKey:@"isLevelCompleted"] boolValue];
        self.isLevelUnlocked = [[data objectForKey:@"isLevelUnlocked"] boolValue];
        self.name = [data objectForKey:@"name"];
        self.duration = [[data objectForKey:@"duration"] intValue];
        self.soundfile = [data objectForKey:@"sound"];
        self.backgroundImage = [data objectForKey:@"background"];
        self.score = [[data objectForKey:@"score"] integerValue];
        self.bestScore = [[data objectForKey:@"bestScore"] integerValue];
    }
    return self;
}

-(void)updateWithDictionary:(NSDictionary*)data
{
    id baskets = [data objectForKey:@"baskets"];
    if(baskets){
        self.baskets = baskets;
    }
    
    id elements = [data objectForKey:@"elements"];
    if(elements){
        self.items = [NSMutableArray array];
        [elements enumerateObjectsUsingBlock:^(NSMutableDictionary *obj, NSUInteger idx, BOOL *stop) {
            KKItemModal *item = [[KKItemModal alloc] initWithDictionary:obj];
            if(item)
                [self.items addObject:item];
        }];
    }
}

-(NSMutableDictionary*)itemsData
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSMutableArray *elements = [NSMutableArray array];
    [self.items enumerateObjectsUsingBlock:^(KKItemModal *obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *itemDict = [obj savedDictionary];
        [elements addObject:itemDict];
    }];
    [dict setObject:elements forKey:@"elements"];
    
    if(self.baskets){
        [dict setObject:self.baskets forKey:@"baskets"];
    }
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)self.levelID] forKey:@"ID"];

    return dict;
}

-(NSMutableDictionary*)savedDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if(self.backgroundImage){
        [dict setObject:self.backgroundImage forKey:@"background"];
    }
    [dict setObject:[NSNumber numberWithInt:(int)self.noOfStars] forKey:@"stars"];
    [dict setObject:[NSNumber numberWithBool:self.isLevelCompleted] forKey:@"isLevelCompleted"];
    [dict setObject:[NSNumber numberWithBool:self.isLevelUnlocked] forKey:@"isLevelUnlocked"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)self.levelID] forKey:@"ID"];
    [dict setObject:self.menuIconImage forKey:@"menuImage"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)self.duration] forKey:@"duration"];
    [dict setObject:self.name forKey:@"name"];
    [dict setObject:self.soundfile forKey:@"sound"];
    [dict setObject:[NSNumber numberWithInteger:self.score] forKey:@"score"];
    [dict setObject:[NSNumber numberWithInteger:self.bestScore] forKey:@"bestScore"];
    return dict;
}

@end
