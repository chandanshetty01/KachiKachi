//
//  KKGameSceneController.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface KKGameSceneController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property(nonatomic,assign) NSInteger currentItemID;
@property(nonatomic,assign) NSInteger currentLevel;
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) UIImageView *basketImageView;

@end
