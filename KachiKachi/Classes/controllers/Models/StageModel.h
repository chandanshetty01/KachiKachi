//
//  StageModel.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StageModel : NSObject
{
    
}
-(id)initWithDictionary:(NSDictionary*)data;
-(NSMutableDictionary*)savedDictionary;
-(NSMutableDictionary*)itemsDictionaryForLevel:(NSInteger)levleID;

@property(nonatomic,assign)BOOL isLocked;
@property(nonatomic,strong)NSMutableArray *levels;

@end
