//
//  ViewController.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKLevelModal.h"

@interface KKLevelSelectViewController : UIViewController

@property(nonatomic,assign) NSInteger currentStage;
@property(nonatomic,strong) NSMutableArray *levelModals;
@property(nonatomic,strong) KKLevelModal *levelModal;

@end
