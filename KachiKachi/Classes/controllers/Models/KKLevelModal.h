//
//  KKLevelModel.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    eNormalMode = 0,
    eTimerMode,
}EGAMEMODE;

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
@property(nonatomic,assign)NSInteger duration;
@property(nonatomic,assign)EGAMEMODE gameMode;
@property(nonatomic,strong)NSString* name;
@property(nonatomic,strong)NSString *soundfile;
@property(nonatomic,assign)NSInteger noOfStars;

-(instancetype)initWithDictionary:(NSDictionary*)data;
-(NSMutableDictionary*)savedDictionary;

@end
