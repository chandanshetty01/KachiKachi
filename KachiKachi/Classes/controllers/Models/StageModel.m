//
//  StageModel.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "StageModel.h"
#import "KKLevelModal.h"

@implementation StageModel

-(id)initWithDictionary:(NSDictionary*)data
{
    self = [super init];
    if(self){
        self.isLocked = [[data objectForKey:@"locked"] boolValue];
        NSMutableArray *levels = [data objectForKey:@"levels"];
        self.levels = [NSMutableArray array];
        [levels enumerateObjectsUsingBlock:^(NSDictionary *data, NSUInteger idx, BOOL *stop) {
            KKLevelModal *level = [[KKLevelModal alloc] initWithDictionary:data];
            [self.levels addObject:level];
        }];
    }
    return self;
}

-(NSMutableDictionary*)itemsDictionaryForLevel:(NSInteger)levleID
{
    __block NSMutableDictionary *data = nil;
    [self.levels enumerateObjectsUsingBlock:^(KKLevelModal *obj, NSUInteger idx, BOOL *stop) {
        if(obj.levelID == levleID){
           data = [obj itemsData];
            *stop = YES;
        }
    }];
    return data;
}

-(NSMutableDictionary*)savedDictionary
{
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data setObject:[NSNumber numberWithBool:self.isLocked] forKey:@"locked"] ;
    NSMutableArray *levels = [NSMutableArray array];
    [self.levels enumerateObjectsUsingBlock:^(KKLevelModal *obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *data = [obj savedDictionary];
        if(data){
            [levels addObject:data];
        }
    }];
    [data setObject:levels forKey:@"levels"];
    return data;
}

@end
