//
//  KKStageSelectControllerViewController.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "KKStageSelectController.h"
#import "KKLevelSelectViewController.h"

@interface KKStageSelectController ()

@end

@implementation KKStageSelectController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIButton *button = (UIButton*)sender;
    
    KKLevelSelectViewController *nextVC = (KKLevelSelectViewController *)[segue destinationViewController];
    if([nextVC respondsToSelector:@selector(setCurrentStage:)])
        nextVC.currentStage = button.tag;
    
    NSNumber *stage = [NSNumber numberWithInt:button.tag];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[stage]
                                                     forKeys:@[@"stage"]];
    [Flurry logEvent:@"StageSelect" withParameters:dict];
}

@end
