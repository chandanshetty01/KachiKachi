//
//  KKGameSceneController.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "KKLevelModel.h"
#import "TTBase.h"
#import "TimerObject.h"
#import "iAdViewController.h"
#import "KKGameOverViewController.h"

@interface KKGameSceneController : UIViewController <iAdViewControllerDelegates>

@property(nonatomic,strong) KKLevelModel *levelModel;
@property(nonatomic,strong) NSMutableArray *elements;
@property(nonatomic,weak) TTBase *currentElement;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property(nonatomic,assign) NSInteger currentStage;
@property(nonatomic,assign) NSInteger currentLevel;
@property (weak, nonatomic) IBOutlet UISwitch *switchBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *mailButton;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *bottomStrip;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (nonatomic,strong) iAdViewController *adViewController;
@property(nonatomic,strong)KKGameOverViewController *gameOverController;

@end
