//
//  KKStageSelectControllerViewController.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKStoreManager.h"

#define kTimedMode @"com.kachikachi.mediumlevel"
#define kAdvancedMode @"com.kachikachi.advancestage"

@interface KKStageSelectController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (nonatomic,assign) NSInteger currentStage;

@end
