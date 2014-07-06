//
//  KKGameSceneController.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "KKLevelModal.h"
#import "TTBase.h"
#import "TimerObject.h"
#import "AdViewController.h"

@interface KKGameSceneController : UIViewController

@property(nonatomic,strong) KKLevelModal *levelModel;

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
@property (weak, nonatomic) IBOutlet UILabel *lifeLabel;
@property (nonatomic,assign) NSInteger noOfLifesRemaining;
@property (nonatomic,assign) NSInteger duration;
@property (nonatomic,assign) EGAMEMODE gameMode;
@property (nonatomic,strong) TimerObject *timer;
@property (nonatomic,strong) AdViewController *adViewController;
@end
