//
//  KKItemModel.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKItemModal : NSObject

@property(nonatomic,strong) NSString *className;
@property(nonatomic,assign) CGRect frame;
@property(nonatomic,strong) NSString *imagePath;
@property(nonatomic,strong) NSArray *touchPoints;
@property(nonatomic,assign) CGFloat angle;
@property(nonatomic,strong) NSDictionary *animation;

-(id)initWithDictionary:(NSDictionary*)data;
-(NSMutableDictionary*)savedDictionary;

@end
