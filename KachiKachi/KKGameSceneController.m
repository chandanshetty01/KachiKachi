//
//  KKGameSceneController.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "KKGameSceneController.h"
#import "TTBase.h"
#import "Utility.h"
#import "SoundManager.h"
#import <Math.h>
#import "AppDelegate.h"
#import "KKMailComposerManager.h"
#import "KKItemModal.h"
#import "KKGameStateManager.h"
#import <Crashlytics/Crashlytics.h>
#import <Social/Social.h>
#import "MKStoreManager.h"
#import "KKCustomAlertViewController.h"
#import "Utility.h"
#import "TTMagicStick.h"

#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+1) - (__MIN__)))
#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

#define LEVEL_INFO @"levelInfo"
#define LEVEL_INFO_LIFE @"levelLife"
#define LEVEL_WON @"levelWon"

const NSInteger kPointsToUnlockLevel = 100;
const NSInteger kMagicStickUsageCount = 5;
const NSInteger kMaxMagicStick = 3;

typedef enum {
    eGameWonAlertID = 100,
    eGameLostAlertID,
    eTutorialAlertID,
    ePurchasePointsID
}ALERT_ID;

typedef enum {
    ePurchasePoints100ID,
    ePurchasePoints200ID,
    ePurchasePoints400ID
}PURCHASEPOINTS_ID;

static int testCounter = 0;

@interface KKGameSceneController ()

@property(nonatomic,strong) NSMutableArray *deletedElements;
@property(nonatomic,strong) NSMutableArray *tempElements;
@property(nonatomic,strong) NSMutableArray *basketElements;
@property(nonatomic,assign) BOOL isGameFinished;
@property(nonatomic,weak) TTBase* topElement;
@property(weak, nonatomic) IBOutlet UILabel *timerLabel;
@property(weak, nonatomic) IBOutlet UIButton *magicStick;
@property(assign, nonatomic) BOOL isMagicStickMode;
@property(weak, nonatomic) IBOutlet UIButton *magicStickBtn;
@property(strong, nonatomic)  TTMagicStick *magicStickAnimation;
@property(nonatomic,assign)NSInteger magicStickCounter;
@property(weak, nonatomic) IBOutlet UIView *magicStickHolder;
@property(weak, nonatomic) IBOutlet UILabel *magicStickLabel;
@property(nonatomic,assign) NSInteger wrongPickCount;
@end

typedef void (^completionBlk)(BOOL);

@implementation KKGameSceneController

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
    
    self.wrongPickCount = 0;
    _elements = [[NSMutableArray alloc] init];
    self.basketElements = [[NSMutableArray alloc] init];
    self.deletedElements = [[NSMutableArray alloc] init];
    [self.homeButton setTitle:NSLocalizedString(@"BACK", "back") forState:UIControlStateNormal];
    
    self.currentLevel = [[KKGameStateManager sharedManager] currentLevelNumber];
    self.currentStage = [[KKGameStateManager sharedManager] currentStageNumber];
    [self updatePointsEarned:0];
    
#ifndef DEVELOPMENT_MODE
    BOOL canRemoveAds = [[KKGameStateManager sharedManager] getCanRemoveAds];
    if([MKStoreManager isFeaturePurchased:kTimedMode] || [MKStoreManager isFeaturePurchased:kAdvancedMode] || canRemoveAds){
        //If purchased do not show any Ads
    }
    else{
        //show Ads
        NSString *name = @"Main_iPad";
        if(!IS_IPAD){
            name = @"Main_iPhone";
        }
        self.adViewController = [[UIStoryboard storyboardWithName:name bundle:nil] instantiateViewControllerWithIdentifier:@"adViewController"];

        [self.view addSubview:self.adViewController.view];
        self.adViewController.delegate = self;
        CGRect frame = self.adViewController.view.frame;
        frame.origin = CGPointZero;
        self.adViewController.view.frame = frame;
    }
#endif

        _isGameFinished = FALSE;
    self.duration = self.levelModel.duration;
    
    [self showTutorial:2];
    [self updateTimer:self.levelModel.duration];
    [self addElements:NO];
    
#ifdef DEVELOPMENT_MODE
    _switchBtn.hidden = NO;
    _saveBtn.hidden = NO;
    _mailButton.hidden = NO;
    _addButton.hidden = NO;
#else
    _switchBtn.hidden = YES;
    _saveBtn.hidden = YES;
    _mailButton.hidden = YES;
    _addButton.hidden = YES;
#endif
    
    [_switchBtn setOn:NO];
    
    [[SoundManager sharedManager] playMusic:@"lovesong"];
    [self updateUI];
    
    //testing code
//    [[KKGameStateManager sharedManager] setMagicStickUsageCount:3];
    //till here
    
    self.magicStickCounter = 0;
    
    [self updateMagicStic];
    [self stageInformationFlurry];
    [self updateMagicStickBtnPosition];
    testCounter = 0;
}

-(void)setMagicStickCounter:(NSInteger)magicStickCounter
{
    _magicStickCounter = magicStickCounter;
    if(self.magicStickAnimation){
        [self.magicStickAnimation updateCount:magicStickCounter];
    }
}

-(void)updateMagicStickBtnPosition
{
    [self.view bringSubviewToFront:self.magicStickHolder];
    if(IS_IPAD){
        CGRect frame = self.magicStickHolder.frame;
        switch (self.currentLevel) {
            case 4:{
                frame.origin = CGPointMake(50,self.view.bounds.size.width-frame.size.height-50);
            }
                break;
                
            case 5:{
                frame.origin = CGPointMake(self.view.bounds.size.height-frame.size.width-100,self.view.bounds.size.width-frame.size.height-100);
            }
                break;
                
            case 18:{
                frame.origin = CGPointMake(0,100);
            }
                break;
                
            default:{
                frame.origin = CGPointMake(self.view.bounds.size.height-frame.size.width, 0);
            }
                break;
        }
        self.magicStickHolder.frame = frame;
    }
}

-(void)showMagicStickAnimation
{
    if(!self.magicStickAnimation){
        self.magicStickAnimation = [[TTMagicStick alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.magicStickAnimation];
        [self.magicStickAnimation startAnimation];
    }
}

-(void)removeMagicStickAnimation
{
    if(self.magicStickAnimation){
        [self.magicStickAnimation stopAnimation];
        [self.magicStickAnimation removeFromSuperview];
        self.magicStickAnimation = nil;
    }
}

-(void)setIsMagicStickMode:(BOOL)isMagicStickMode
{
    _isMagicStickMode = isMagicStickMode;
    if(isMagicStickMode){
        [self showMagicStickAnimation];
    }
    else{
        [self removeMagicStickAnimation];
    }
}

-(void)updateMagicStic
{
    NSInteger usageCount = [[KKGameStateManager sharedManager] getmagicStickUsageCount];
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"MAGIC_STICK",nil),usageCount];
    [self.magicStick setTitle:title forState:UIControlStateNormal];
    self.magicStickLabel.text = [NSString stringWithFormat:@"%ld",(long)usageCount];
    if(usageCount > 0){
        self.magicStick.alpha = 1.0;
    }
    else{
        self.magicStick.alpha = 0.7;
    }
}

- (IBAction)handleMagicStickAction:(id)sender
{
    if(self.isMagicStickMode)
        return;
    
    NSInteger usageCount = [[KKGameStateManager sharedManager] getmagicStickUsageCount];
    NSString *name = @"Main_iPad";
    if(!IS_IPAD){
        name = @"Main_iPhone";
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:name bundle:nil];
    KKCustomAlertViewController *alertview = [storyBoard instantiateViewControllerWithIdentifier:@"KKCustomAlertViewController"];
    if(usageCount > 0){
        [alertview addButtonWithTitle:NSLocalizedString(@"OK", nil)];
        [alertview addButtonWithTitle:NSLocalizedString(@"CANCEL", nil)];
        [alertview showAlertWithTitle:NSLocalizedString(@"MAGIC_STICK_USAGE", nil)
                              message:[NSString stringWithFormat:NSLocalizedString(@"MAGIC_STICK_USAGE_DESC",nil),kMagicStickUsageCount]
                          buttonTitle:NSLocalizedString(@"OK", nil)
                         inController:self
                           completion:^(NSInteger index) {
                               if(index == 0){
                                   [Flurry logEvent:@"magicstick_used"];
                                   self.isMagicStickMode = YES;
                                   [[KKGameStateManager sharedManager] setMagicStickUsageCount:usageCount-1];
                                   self.magicStickCounter = kMagicStickUsageCount;
                               }
                           }];
    }
    else{

        [alertview showAlertWithTitle:NSLocalizedString(@"MAGIC_STICK_NO_POINTS_TITLE", nil)
                              message:NSLocalizedString(@"MAGIC_STICK_NO_POINTS_DESC", nil)
                          buttonTitle:NSLocalizedString(@"OK", nil)
                         inController:self
                           completion:nil];
    }
}

-(void)stageInformationFlurry
{
    NSMutableDictionary *levelInfo = [[NSMutableDictionary alloc] init];
    [levelInfo setObject:[NSString stringWithFormat:@"%@",self.levelModel.name] forKey:[NSString stringWithFormat:@"%ld",(long)self.currentStage]];
    [Flurry logEvent:@"stage_information" withParameters:levelInfo];
}

-(void)showTutorial : (NSInteger)tutorialID
{
    if(tutorialID == 1){
        BOOL isTutorialShown = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TUTORIAL_1"] boolValue];
        if(!isTutorialShown){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HOW_TO_PLAY", nil)
                                                            message:NSLocalizedString(@"TUTORIAL_1", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            
            [alert show];
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"TUTORIAL_1"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    else if(tutorialID == 2){
        BOOL isTutorialShown = [[[NSUserDefaults standardUserDefaults] objectForKey:@"TUTORIAL_2"] boolValue];
        if(!isTutorialShown){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"HOW_TO_PLAY", nil)
                                                            message:NSLocalizedString(@"TUTORIAL_2", nil)
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            alert.tag = eTutorialAlertID;
            [alert show];
            [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"TUTORIAL_2"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else{
            [self startTimer];
        }
    }
}

-(void)startTimer
{
    self.timer = [[TimerObject alloc] initWithDuration:self.levelModel.duration fireInterval:1.0f];
    [self.timer startTimer];
    self.timer.delegate = self;
    self.timerLabel.hidden = NO;
}

-(void)stopTimer
{
    if(self.timer){
        [self.timer pauseTimer];
        self.timer = nil;
    }
}

-(void)updatePointsEarned:(NSInteger)inPoints
{

}

-(void)updateTimer:(NSInteger)remainingTime
{
    NSString *time = [NSString stringWithFormat:NSLocalizedString(@"TIME", @"time remainging %d"),(long)remainingTime];
    [self.timerLabel setText:time];
}

#pragma mark - Timer delegates -
-(void)timerDidCompleted:(TimerObject*)timer
{
    self.levelModel.duration = 0;
    [self updateTimer:self.levelModel.duration];
    [self validateGamePlay:^(BOOL finished) {
        _currentElement = nil;
    }];
}

-(void)timerDidTick:(NSTimeInterval)remainingInteval andTimer:(TimerObject*)timer
{
    self.levelModel.duration = remainingInteval;
    [self updateTimer:self.levelModel.duration];
}

-(void)postFlurry:(NSString*)status
{
    NSMutableDictionary *levelInfo = [[NSMutableDictionary alloc] init];
    [levelInfo setObject:status forKey:@"status"];
    
    NSString *key = [NSString stringWithFormat:@"Level(%@)Stage(%ld)",self.levelModel.name,(long)self.levelModel.stageID];
    [Flurry logEvent:key withParameters:levelInfo];
}

-(void)addElements:(BOOL)isRestartMode
{
    [self.levelModel.items enumerateObjectsUsingBlock:^(KKItemModal *obj, NSUInteger idx, BOOL *stop) {
        [self generateElement:obj];
    }];
    
    self.topElement = [self.elements lastObject];
    
    if(!isRestartMode){
        UIImage *image = [UIImage imageNamed:self.levelModel.backgroundImage];
        self.background.image = image;
    }
    
    [self.levelModel.baskets enumerateObjectsUsingBlock:^(NSDictionary *basket, NSUInteger idx, BOOL *stop) {
        UIImage *image = [UIImage imageNamed:[basket objectForKey:@"basket"]];
        CGRect frame = CGRectZero;
        frame.origin =CGPointFromString([basket objectForKey:@"basket_frame"]);
        frame.size = image.size;
        
        UIImageView *basketView = [[UIImageView alloc] initWithFrame:frame];
        basketView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        basketView.image = image;
        [self.basketElements addObject:basketView];
        
        if(IS_IPAD){
            //for iPad
            KKItemModal *item = [self.levelModel.items objectAtIndex:0];
            if([item.className isEqualToString:@"TTBird"] ||
               ([item.className isEqualToString:@"TTCandle"] && [[basket objectForKey:@"basket"] isEqualToString:@"candle_basket2.png"]) ||
               ([item.className isEqualToString:@"TTDvd"] && [[basket objectForKey:@"basket"] isEqualToString:@"cd_basket1.png"]) ||
               ([item.className isEqualToString:@"TTUmbrella"]) || ([item.className isEqualToString:@"TTKey"]) ||
               ([item.className isEqualToString:@"TTBrush"] && ([[basket objectForKey:@"basket"] isEqualToString:@"toothbrush_container1.png"] || [[basket objectForKey:@"basket"] isEqualToString:@"toothbrush_container2.png"])))
            {
                [self.view insertSubview:basketView aboveSubview:self.background];
            }
            else
            {
                [self.view addSubview:basketView];
                [self.view bringSubviewToFront:self.bottomStrip];
            }
        }
        else{
            //iPhone related changes
            KKItemModal *item = [self.levelModel.items objectAtIndex:0];
            if(([item.className isEqualToString:@"TTFish"] && !(([[basket objectForKey:@"basket"] isEqualToString:@"iPh_bucket_front_part.png"]) || ([[basket objectForKey:@"basket"] isEqualToString:@"iPh_handel.png"]))) || ([item.className isEqualToString:@"TTChoc"] && [[basket objectForKey:@"basket"] isEqualToString:@"iPh_candy_back_part.png"]) || [item.className isEqualToString:@"TTBird"] || ([item.className isEqualToString:@"TTCandle"] && [[basket objectForKey:@"basket"] isEqualToString:@"iph_candle_stand1.png"]) || ([item.className isEqualToString:@"TTDvd"] && ![[basket objectForKey:@"basket"] isEqualToString:@"iph_cd_holder2.png"]) || ([item.className isEqualToString:@"TTUmbrella"]) || ([item.className isEqualToString:@"TTBrush"] && ([[basket objectForKey:@"basket"] isEqualToString:@"iPh_brush1_cup1.png"] || [[basket objectForKey:@"basket"] isEqualToString:@"iPh_brush1_cup2.png"])) || [item.className isEqualToString:@"TTKey"])
            {
                [self.view insertSubview:basketView aboveSubview:self.background];
            }
            else
            {
                [self.view addSubview:basketView];
                [self.view bringSubviewToFront:self.bottomStrip];
            }
        }
    }];
}

-(void)generateElement:(KKItemModal*)itemModel
{
    TTBase *object = [[NSClassFromString(itemModel.className) alloc] init];
    [object initWithModal:itemModel];
    if(object.image){
        [self.view addSubview:object];
        if(object.isPicked){
            [object setPickedObjectPosition];
        }
        [_elements addObject:object];
    }
}

-(BOOL)isGameOver
{
    BOOL gameOver = FALSE;
    
    NSMutableArray *intersectedElements = [self intersectedElements:_currentElement];
    
#ifdef DEVELOPMENT_MODE
    return gameOver;
#endif
    
    NSInteger currentElementIndex = [_elements indexOfObject:_currentElement];
    for (TTBase *element in intersectedElements) {
        NSInteger index = [_elements indexOfObject:element];
        if(currentElementIndex < index && !self.isMagicStickMode)
        {
            gameOver = true;
            break;
        }
    }
    
    if(gameOver){
        [_currentElement shakeAnimation];
        [self updateWrongPick];
        self.currentElement = nil;
    }
    else{
        self.wrongPickCount = 0;
    }
    
    return gameOver;
}

-(NSInteger)noOfObjectsToBePicked
{
    __block int count = 0;
    [self.elements enumerateObjectsUsingBlock:^(TTBase *obj, NSUInteger idx, BOOL *stop) {
        if(!obj.isPicked)
            count++;
    }];
    return count;
}

-(BOOL)isGameWon
{
#ifdef DEVELOPMENT_MODE
    return false;
#endif
    if([self noOfObjectsToBePicked] <= 1)
        return TRUE;
    return FALSE;
}


-(CGFloat)degreesToRadian:(CGFloat)angle{
    return angle * (3.14/180);
}

-(CGFloat)radianToDegree:(CGFloat)radian{
    return radian * (180/3.14);
}

-(void)showElementDissapearAnimation:(completionBlk)block
{
    [self.deletedElements enumerateObjectsUsingBlock:^(TTBase *obj, NSUInteger idx, BOOL *stop) {
        if(!obj.isPicked){
            obj.isPicked = YES;
            self.view.userInteractionEnabled = NO;
            [obj showAnimation:^(BOOL canRemoveObject) {
                [self.deletedElements removeObject:obj];
                self.view.userInteractionEnabled = YES;
                block(YES);
            }];
        }
    }];
}

-(void)updateUI
{
    
}

-(void)saveLevelData
{
    NSMutableDictionary *levelDict = [self.levelModel savedDictionary];
    
    if([self.elements count] > 0)
    {
        NSMutableArray *elements = [NSMutableArray array];
        [self.elements enumerateObjectsUsingBlock:^(TTBase *obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *itemDict = [obj saveDictionary];
            [elements addObject:itemDict];
        }];
        [levelDict setObject:elements forKey:@"elements"];
    }
    
    [[KKGameStateManager sharedManager] setData:levelDict level:self.currentLevel stage:self.currentStage];
    
    [[KKGameStateManager sharedManager]save];
}

-(void)showGameOverAlert:(NSDictionary*)data
{
    [[SoundManager sharedManager] playSound:@"wrong" looping:NO];
    NSString *msg = [data objectForKey:@"msg"];
    NSString *name = @"Main_iPad";
    if(!IS_IPAD){
        name = @"Main_iPhone";
    }
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:name bundle:nil];
    KKCustomAlertViewController *alertview = [storyBoard instantiateViewControllerWithIdentifier:@"KKCustomAlertViewController"];
    alertview.view.tag = 1;
    alertview.canDismissOnButtonPress = NO;
    
    BOOL isNextLevelUnlocked = [self isNextLevelUnlocked];
    if(!isNextLevelUnlocked){
        //REPLAY
        //MAIN_MENU
        //UNLOCK_NEXT_LEVEL
        [alertview addButtonWithTitle:NSLocalizedString(@"REPLAY", nil)];
        [alertview showAlertWithTitle:NSLocalizedString(@"GAME_OVER", nil)
                              message:msg
                          buttonTitle:NSLocalizedString(@"MAIN_MENU", nil)
                         inController:self
                           completion:^(NSInteger index) {
                               if(index == 1){
                               }
                               else if(index == 0){
                                   [alertview removeController:^(NSInteger index) {
                                       //Main Menu
                                       _isGameFinished = NO;
                                       [self moveToLevelSelectScene];
                                   }];
                               }
                               else if(index == 2){
                                   [alertview removeController:^(NSInteger index) {
                                       //Main Menu
                                       _isGameFinished = NO;
                                       [self replayLevel];
                                   }];
                               }
                           }];
    }
    else{
        [alertview addButtonWithTitle:NSLocalizedString(@"REPLAY", nil)];
        [alertview showAlertWithTitle:NSLocalizedString(@"GAME_OVER", nil)
                              message:msg
                          buttonTitle:NSLocalizedString(@"MAIN_MENU", nil)
                         inController:self
                           completion:^(NSInteger index) {
                               if(index == 0){
                                   [alertview removeController:^(NSInteger index) {
                                       //Main Menu
                                       _isGameFinished = NO;
                                       [self moveToLevelSelectScene];
                                   }];
                               }
                               else if(index == 1){
                                   [alertview removeController:^(NSInteger index) {
                                       //Main Menu
                                       _isGameFinished = NO;
                                       [self replayLevel];
                                   }];
                               }
                           }];
    }

}

#pragma mark - social integration

-(void)facebookShare
{
    SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            [fbController dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    [Flurry logEvent:@"facebook-cancelled"];
                    [self moveToLevelSelectScene];
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    [Flurry logEvent:@"facebook-posted"];
                    [self moveToLevelSelectScene];
                }
                    break;
            }};
        
        NSString *mode = @"Easy";
        switch (self.currentStage) {
            case 2:
                mode = @"Timed";
                break;
            case 3:
                mode = @"Hard";
                break;
            default:
                break;
        }
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"FB_SHARE_MSG", nil),self.levelModel.name,mode];
        //[fbController addImage:[UIImage imageNamed:@"share_icon.png"]];
        [fbController setInitialText:msg];
        [fbController addURL:[NSURL URLWithString:APP_URL]];
        [fbController setCompletionHandler:completionHandler];
        [self presentViewController:fbController animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FB_NOT_CONFIGURED_TITLE", nil)
                                                        message:NSLocalizedString(@"FB_NOT_CONFIGURED_MSG", nil)
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}

-(void)twitterShare
{
    SLComposeViewController *shareController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            [shareController dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    [Flurry logEvent:@"Twitter-cancelled"];
                    [self moveToLevelSelectScene];
                    
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    [Flurry logEvent:@"Twitter-posted"];
                    [self moveToLevelSelectScene];
                }
                    break;
            }};
        
        NSString *mode = @"Easy";
        switch (self.currentStage) {
            case 2:
                mode = @"Timed";
                break;
            case 3:
                mode = @"Hard";
                break;
            default:
                break;
        }
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"TWITTER_SHARE_MSG", nil),self.levelModel.name,mode];
        //[shareController addImage:[UIImage imageNamed:@"share_icon.png"]];
        [shareController setInitialText:msg];
        [shareController addURL:[NSURL URLWithString:APP_URL]];
        [shareController setCompletionHandler:completionHandler];
        [self presentViewController:shareController animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TWITTER_NOT_CONFIGURED_TITLE", nil)
                                                        message:NSLocalizedString(@"TWITTER_NOT_CONFIGURED_MSG", nil)
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)showGameWonAlert:(BOOL)canShowMagicStickMsg
{
    [[SoundManager sharedManager] playSound:@"won" looping:NO];

    NSString *btnTitle = NSLocalizedString(@"PLAY_NEXT_LEVEL", nil);
    NSString *magicStick = @"";
    if(self.levelModel.noOfStars == 3 && canShowMagicStickMsg){
        magicStick = NSLocalizedString(@"WON_MAGIC_STICK", nil);
    }

    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"CONGRATS_LEVEL_COMPLETION", nil),self.levelModel.noOfStars,magicStick] ;
    if(self.currentLevel >= [[KKGameConfigManager sharedManager] totalNumberOfLevelsInStage:self.currentStage]-1){
        msg = [NSString stringWithFormat:NSLocalizedString(@"CONGRATS_STAGE_COMPLETION", nil),self.levelModel.noOfStars,magicStick];
        btnTitle = NSLocalizedString(@"PLAY_NEXT_STAGE", nil);
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"GAME_WON", nil)
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:btnTitle
                                          otherButtonTitles:nil];
    alert.tag = eGameWonAlertID;
    [alert addButtonWithTitle:NSLocalizedString(@"FACEBOOK_SHARE", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"TWEET", nil)];
    [alert show];
}

-(void)playSound:(NSString*)soundFile
{
    [[SoundManager sharedManager] playSound:soundFile looping:NO];
}

-(void)saveGame
{
    [self saveLevelData];
}

-(void)highlightTopObject
{
    NSEnumerator *enumerator = [_elements reverseObjectEnumerator];
    for (TTBase *obj in enumerator) {
        if(!obj.isPicked){
            obj.isHighlighted = YES;
            break;
        }
    }
}

-(void)updateWrongPick
{
    NSInteger wrongObjCount = 3;
    if(self.currentStage == 1){
        if(self.currentLevel == 1){
            wrongObjCount = 1;
        }
        else if(self.currentLevel == 2){
            wrongObjCount = 2;
        }
    }
    
    self.wrongPickCount++;
    if(self.wrongPickCount == wrongObjCount){
        [self highlightTopObject];
        self.wrongPickCount = 0;
    }
}

-(void)validateGamePlay:(completionBlk)block
{
    if([self isGameOver] && !_isGameFinished)
    {
        NSDictionary *data = @{@"msg":NSLocalizedString(@"GAME_OVER_MSG", nil)};
        [[SoundManager sharedManager] playSound:@"wrong" looping:NO];
        [self updateUI];
        
        if(NO){
            [self postFlurry:@"LOST"];
            [self stopTimer];
            self.currentElement = nil;
            _isGameFinished = YES;
            NSInteger stars = self.levelModel.noOfStars;
            [self restartGame];
            self.levelModel.noOfStars = stars;
            [self saveGame];
            [self performSelector:@selector(showGameOverAlert:) withObject:data afterDelay:0.5];
        }
        block(YES);
    }
    else if([self isGameWon])
    {
        NSInteger starWon = [self getStarWon];
        NSInteger stars = [self updateStars];
        [self unlockNextLevel];
        //Add level save related data after unlockNextLevel
        self.levelModel.noOfStars = stars;
        [self saveGame];
        [self stopTimer];
        
        BOOL showMagicStickMsg = NO;
        if(starWon == 3){
            showMagicStickMsg = YES;
        }
        [self showGameWonAlert:showMagicStickMsg];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:[NSString stringWithFormat:@"%ld(l)_%ld(s)[%ld(star)]",(long)self.currentLevel,(long)self.currentStage,(long)stars] forKey:@"level"];
        [Flurry logEvent:@"stars" withParameters:dictionary];
        
        [self postFlurry:@"WON"];
        
        block(YES);
    }
    else if(_currentElement != nil)
    {
        [self playSound:self.levelModel.soundfile];
#ifndef DEVELOPMENT_MODE
        [self.deletedElements addObject:_currentElement];
        [self showElementDissapearAnimation:block];
        
        if(self.isMagicStickMode){
            self.magicStickCounter--;
            if(self.magicStickCounter == 0){
                self.isMagicStickMode = FALSE;
                self.magicStickCounter = 0;
            }
            [self updateMagicStic];
        }
#endif
    }
}

-(void)updatePoints:(NSInteger)oldStar andNewStar:(NSInteger)newStar
{
    NSInteger points = 0;
    if(oldStar == -1)
        oldStar = 0;
        
    points = (newStar-oldStar)*10;
    if(points > 0){
        [self updatePointsEarned:points];
    }
}

-(NSInteger)getStarWon
{
    NSInteger newStar = 1;
    return newStar;
}

-(NSInteger)updateStars
{
    NSInteger oldStar = self.levelModel.noOfStars;
    NSInteger newStar = [self getStarWon];
    [self updatePoints:oldStar andNewStar:newStar];
    
    if(newStar == 3){
        //get a magic stic
        NSInteger count = [[KKGameStateManager sharedManager] getmagicStickUsageCount];
        count = count+1;
        if(count > kMaxMagicStick)
            count = kMaxMagicStick;
        [[KKGameStateManager sharedManager] setMagicStickUsageCount:count];
    }

    if (newStar > oldStar) {
        oldStar = newStar;
    }
    return oldStar;
}

-(void)restartGame
{
    self.tempElements = [[NSMutableArray alloc] initWithArray:self.elements];
    [self.elements removeAllObjects];
    
    KKGameConfigManager *config = [KKGameConfigManager sharedManager];
    NSDictionary *tLevel = [config levelWithID:self.currentLevel andStage:self.currentStage];
    BOOL isLevelCompleted = self.levelModel.isLevelCompleted;
    self.levelModel = [[KKLevelModal alloc] initWithDictionary:tLevel];
    self.levelModel.levelID = self.currentLevel;
    self.levelModel.stageID =  self.currentStage;
    self.levelModel.isLevelUnlocked = YES;
    self.levelModel.isLevelCompleted = isLevelCompleted;
}

-(BOOL)isNextLevelUnlocked
{
    BOOL isUnlocked = NO;
    NSInteger nextlevel = self.currentLevel+1;
    NSInteger noOfLevels = [[KKGameConfigManager sharedManager] totalNumberOfLevelsInStage:self.currentStage];
    if(nextlevel <= noOfLevels){
        isUnlocked = [[KKGameStateManager sharedManager] isLevelUnlocked:self.currentLevel+1 stage:self.currentStage];
    }
    else{
        isUnlocked = ![[KKGameStateManager sharedManager] isStageLocked:self.currentStage+1];
    }
    return isUnlocked;
}

-(void)unlockNextLevel
{
    //Dont reset the entire thing... just reset items
    self.tempElements = [[NSMutableArray alloc] initWithArray:self.elements];
    [self.elements removeAllObjects];
    
    KKGameConfigManager *config = [KKGameConfigManager sharedManager];
    NSDictionary *tLevel = [config levelWithID:self.currentLevel andStage:self.currentStage];
    self.levelModel = [[KKLevelModal alloc] initWithDictionary:tLevel];
    self.levelModel.isLevelUnlocked = YES;
    self.levelModel.isLevelCompleted = YES;
    
    self.levelModel.duration = [[KKGameConfigManager sharedManager] durationForLevel:self.currentLevel stage:self.currentStage];
    NSInteger nextlevel = self.currentLevel+1;
    NSInteger noOfLevels = [[KKGameConfigManager sharedManager] totalNumberOfLevelsInStage:self.currentStage];
    if(nextlevel <= noOfLevels){
        [[KKGameStateManager sharedManager] markUnlocked:self.currentLevel stage:self.currentStage];
        [[KKGameStateManager sharedManager] markUnlocked:self.currentLevel+1 stage:self.currentStage];
    }
    else{
        [[KKGameStateManager sharedManager] unlockStage:self.currentStage+1];
    }
}

-(NSMutableArray*)intersectedElements:(TTBase*)currentElement
{
    NSMutableArray *intersectedElements = [NSMutableArray array];
    
    NSMutableArray *polygonB = [NSMutableArray array];
    for(NSString *point in currentElement.touchPoints){
        CGPoint cPoint = CGPointFromString(point);
        cPoint.x = cPoint.x+currentElement.frame.origin.x;
        cPoint.y = cPoint.y+currentElement.frame.origin.y;
        // CGPoint rotatedPoint = [self rotatePoint:cPoint andAngle:self.angle];
        [polygonB addObject:NSStringFromCGPoint(cPoint)];
    }
    
    for (TTBase *element in _elements) {
        if(![element isEqual:currentElement] && !element.isPicked){
            
            NSMutableArray *polygonA = [NSMutableArray array];
            for(NSString *point in element.touchPoints){
                CGPoint cPoint = CGPointFromString(point);
                cPoint.x = cPoint.x+element.frame.origin.x;
                cPoint.y = cPoint.y+element.frame.origin.y;
                // CGPoint rotatedPoint = [self rotatePoint:cPoint andAngle:self.angle];
                [polygonA addObject:NSStringFromCGPoint(cPoint)];
            }
            
            BOOL isIntersected = [Utility isPolygonIntersected:polygonA andPolygon:polygonB];
            if(isIntersected)
                [intersectedElements addObject:element];
        }
    }
    
    return intersectedElements;
}

-(TTBase*)getNearestItem:(CGPoint)touchLocation
{
    TTBase *item = nil;
    
    for (int i = (int)[_elements count]-1; i >= 0; i--) {
        TTBase *element = (TTBase*)[_elements objectAtIndex:i];
        if([element canHandleTouch:touchLocation radius:15]){
            item = element;
            break;
        }
    }
    
    return item;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.isGameFinished)
        return;
    
    _currentElement = nil;
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self.view];
    
//    for (int i = (int)[_elements count]-1; i >= 0; i--) {
//        TTBase *element = (TTBase*)[_elements objectAtIndex:i];
//        if([element canHandleTouch:touchLocation]){
//            _currentElement = element;
//            [_currentElement handleTouchesBegan:touches withEvent:event];
//            break;
//        }
//    }
    
    if(!_currentElement){
        _currentElement = [self getNearestItem:touchLocation];
        [_currentElement handleTouchesBegan:touches withEvent:event];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_currentElement.userInteractionEnabled){
        if([self.switchBtn isOn])
            _currentElement.canSaveTouchPoints = YES;
        else
            _currentElement.canSaveTouchPoints = NO;
        
        if(_currentElement){
            [_currentElement handleTouchesEnded:touches withEvent:event];
        }
        
        [self validateGamePlay:^(BOOL finished) {
            _currentElement = nil;
        }];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_currentElement){
        [_currentElement handleTouchesMoved:touches withEvent:event];
    }
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_currentElement){
        [_currentElement handleTouchesCancelled:touches withEvent:event];
    }
    _currentElement = nil;
}

-(void)moveToLevelSelectScene
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(KKLevelModal*)currentLevelData
{
    KKLevelModal *levelModel = nil;
    KKGameConfigManager *config = [KKGameConfigManager sharedManager];
    NSDictionary *tLevel = [config levelWithID:self.currentLevel andStage:self.currentStage];
    levelModel = [[KKLevelModal alloc] initWithDictionary:tLevel];
    levelModel.levelID = self.currentLevel;
    levelModel.stageID =  self.currentStage;
    return levelModel;
}

-(void)removeAllElements
{
    [self.tempElements enumerateObjectsUsingBlock:^(TTBase *obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.tempElements removeAllObjects];
    
    [self.elements enumerateObjectsUsingBlock:^(TTBase *obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.elements removeAllObjects];
    
    [self.basketElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.basketElements removeAllObjects];
    
    [self.deletedElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.deletedElements removeAllObjects];
}

-(void)logReplayEvent
{
    NSMutableDictionary *levelInfo = [[NSMutableDictionary alloc] init];
    [levelInfo setObject:[NSString stringWithFormat:@"%@",self.levelModel.name] forKey:[NSString stringWithFormat:@"%ld",(long)self.currentStage]];
    [Flurry logEvent:@"replay" withParameters:levelInfo];
}

-(void)replayLevel
{
    NSInteger noOfStars = self.levelModel.noOfStars;
    [self removeAllElements];
    
    _isGameFinished = FALSE;
    self.levelModel = [self currentLevelData];
    self.levelModel.isLevelUnlocked = YES;
    self.levelModel.isLevelCompleted = NO;
    self.levelModel.noOfStars = noOfStars;
    self.duration = self.levelModel.duration;
    
    [self addElements:YES];
    [self updateMagicStic];
    [self updateUI];
    [self updateTimer:self.levelModel.duration];
    [self startTimer];
    
    [self logReplayEvent];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

    switch (alertView.tag) {
        case eGameWonAlertID:
        {
            switch (buttonIndex) {
                case 0:
                {
                    _isGameFinished = NO;
                    [self moveToLevelSelectScene];
                }
                    break;
                case 1:
                    [self facebookShare];
                    break;
                case 2:
                    [self twitterShare];
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case eTutorialAlertID:
        {
            [self startTimer];
        }
            break;
                        
        default:
            break;
    }
}

- (IBAction)backButtonAction:(id)sender
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

    [self postFlurry:@"LEFT"];
    [self saveGame];
    AppDelegate *appdelegate = APP_DELEGATE;
    [appdelegate.navigationController popViewControllerAnimated:YES];
}

- (IBAction)restartButtonAction:(id)sender
{
    
}

- (void)dealloc
{
    self.currentElement = nil;
    [self removeAllElements];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleSwitchBtn:(id)sender
{
    
}

- (IBAction)handleAddBtn:(id)sender
{
    testCounter++;
    if(testCounter >= _elements.count){
        testCounter = 0;
    }
    
    TTBase *tObject = [_elements objectAtIndex:testCounter];
    KKItemModal *itemModel = tObject.itemModal;
    
    CGRect frame = itemModel.frame;
    frame.origin = CGPointMake(10, 10);
    itemModel.frame = frame;
    
    TTBase *newObject = [[NSClassFromString(itemModel.className) alloc] init];
    [newObject initWithModal:itemModel];
    if(newObject.image){
        [self.view addSubview:newObject];
        [_elements addObject:newObject];
    }
}

- (IBAction)handleSaveBtn:(id)sender
{    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSMutableArray *tElements = [NSMutableArray array];
    for (TTBase *element in _elements) {
        [tElements addObject:[element saveDictionary]];
    }
    
    [data setObject:tElements forKey:@"elements"];
    [data writeToFile:@"/Users/chandanshettysp/Desktop/savedData.plist" atomically:YES];
}

-(void)pauseGame
{
    [self stopTimer];
}

-(void)resumeGame
{
    [self startTimer];
}

- (IBAction)handleMailBtn:(id)sender
{
    NSString* plistPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"savedData.plist"];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    NSMutableArray *tElements = [NSMutableArray array];
    for (TTBase *element in _elements) {
        [tElements addObject:[element saveDictionary]];
    }
    [data setObject:tElements forKey:@"data"];
    [data writeToFile:plistPath atomically:YES];
    
    // Attach an image to the email
    NSData *myData = [NSData dataWithContentsOfFile:plistPath];
    NSString *attachmentMime = @"text/xml";
    NSString *attachmentName = @"savedData.plist";
    
    // Fill out the email body text
    NSString *emailBody = @"Hi, \n\n Check out new level data! \n\n\nRegards, \nKachi-Kachi";
    NSString *emailSub = [NSString stringWithFormat:@"KACHI KACHI: Level %ld Stage %ld",(long)self.currentLevel,(long)self.currentStage];
    
    NSArray *toRecipients = [NSArray arrayWithObject:@"chandanshetty01@gmail.com"];
    NSArray *ccRecipients = [NSArray arrayWithObjects:@"26anil.kushwaha@gmail.com", @"ashishpra.pra@gmail.com", nil];
    [[KKMailComposerManager sharedManager] displayMailComposerSheet:self
                                                       toRecipients:toRecipients
                                                       ccRecipients:ccRecipients
                                                     attachmentData:myData
                                                 attachmentMimeType:attachmentMime
                                                 attachmentFileName:attachmentName
                                                          emailBody:emailBody
                                                       emailSubject:emailSub
                                                         completion:nil];
}

#pragma - mark iAd delegates -

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    [self pauseGame];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    [self resumeGame];
}


@end
