//
//  KKLevelModel.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKLevelModal : NSObject

@property(nonatomic,assign)NSInteger levelID;
@property(nonatomic,assign)NSInteger stageID;
@property(nonatomic,strong)NSArray *baskets;
@property(nonatomic,strong)NSString *backgroundImage;
@property(nonatomic,assign)NSInteger life;
@property(nonatomic,strong)NSMutableArray *items;
@property(nonatomic,assign)BOOL isLevelCompleted;
@property(nonatomic,assign)BOOL isLevelUnlocked;
@property(nonatomic,strong)NSString* menuIconImage;

-(instancetype)initWithDictionary:(NSDictionary*)data;
-(NSMutableDictionary*)savedDictionary;

@end
