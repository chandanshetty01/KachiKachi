//
//  ViewController.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "KKLevelSelectViewController.h"
#import "KKGameSceneController.h"
#import "SoundManager.h"
#import "KKLevelModal.h"
#import "kkGameStateManager.h"
#import "KKCollectionViewCell.h"

@interface KKLevelSelectViewController ()
@property (weak, nonatomic) IBOutlet UIView *stageSelectView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation KKLevelSelectViewController

-(void)loadLevelsForStage
{
    self.levelModals = nil;
    self.levelModals = [NSMutableArray array];

    NSMutableDictionary *levels = [[KKGameStateManager sharedManager] levelsDictionary:self.currentStage];
    
    NSArray *keys = [levels allKeys];
    keys = [levels keysSortedByValueUsingComparator: ^(NSDictionary *obj1, NSDictionary *obj2) {
        int val1 = [[obj1 objectForKey:@"ID"] intValue];
        int val2 = [[obj2 objectForKey:@"ID"] intValue];
        if(val1 > val2)
            return NSOrderedDescending;
        else if(val1 < val2)
            return NSOrderedAscending;
        else
            return NSOrderedSame;
        
    }];
    
    [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *level = [levels objectForKey:key];
        KKLevelModal *levelModel = [[KKLevelModal alloc] initWithDictionary:level];
        levelModel.stageID =  _currentStage;
        [self.levelModals addObject:levelModel];
    }];
    
    [self.collectionView reloadData];
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
        
    [self showStageSelectionDialog];
    
    self.currentStage = 1;//default
    //[self loadLevelsForStage];
    
    BOOL isOn = [[KKGameStateManager sharedManager] isSoundEnabled];
    [self.soundSwitch setOn:isOn];

    [self playMusic];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self loadLevelsForStage];
}

-(void)showStageSelectionDialog
{
    self.stageSelectView.hidden = NO;

    [UIView animateWithDuration:0.5
                     animations:^{
                         self.stageSelectView.alpha = 1;
                     } completion:^(BOOL finished) {
                     }];
}

-(void)hideStageSelectionDialog
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.stageSelectView.alpha = 0.0;
                     } completion:^(BOOL finished) {
                         self.stageSelectView.hidden = YES;
                     }];
}

-(void)playMusic
{
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
    [[SoundManager sharedManager] playMusic:@"track1" looping:YES];
}

-(void)stopMusic
{
    [[SoundManager sharedManager] stopMusic];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonAction:(id)sender
{
//    AppDelegate *appdelegate = APP_DELEGATE;
//    [appdelegate.navigationController popViewControllerAnimated:YES];

    [self showStageSelectionDialog];
    
    [Flurry logEvent:@"BackButton - Level Select"];
}

-(KKLevelModal*)currentLevelData:(NSInteger)levelID
{
    NSMutableDictionary *levelDict = [[KKGameStateManager sharedManager] gameData:levelID stage:_currentStage];
#ifdef DEVELOPMENT_MODE
    levelDict = nil;
#endif
    if(levelDict == nil)
    {
        KKLevelModal *levelModel = nil;
        KKGameConfigManager *config = [KKGameConfigManager sharedManager];
        NSDictionary *level = [config levelWithID:levelID andStage:self.currentStage];
        levelModel = [[KKLevelModal alloc] initWithDictionary:level];
        levelModel.levelID = levelID;
        levelModel.stageID =  _currentStage;
        return levelModel;
    }
    else
    {
        KKLevelModal *levelModel = nil;
        levelModel = [[KKLevelModal alloc] initWithDictionary:levelDict];
        levelModel.levelID = levelID;
        levelModel.stageID =  _currentStage;
        return levelModel;
    }
}

#pragma mark - UICollectionView methods -


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.levelModals.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)inCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"collectionViewCell";
    KKCollectionViewCell *cell = [inCollectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.tag = [indexPath row];
    
    KKLevelModal *level = [self.levelModals objectAtIndex:[indexPath row]];
    cell.tag = level.levelID;
    //setImage:[UIImage imageNamed:level.menuIconImage] forState:UIControlStateNormal
    [cell.menuImage setImage:[UIImage imageNamed:level.menuIconImage]];
    cell.menuImage.contentMode = UIViewContentModeCenter;
    
    if(level.isLevelUnlocked){
        cell.lockHolderView.hidden = YES;
    }
    else{
        cell.lockHolderView.hidden = NO;
    }
    
    return cell;
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
#ifdef ENABLE_ALL_LEVELS
    return YES;
#endif
    UIView *btn = (UIView*)sender;
    KKLevelModal *modal = [self currentLevelData:btn.tag];
    if(modal){
    [Flurry logEvent:[NSString stringWithFormat:@"Level-%@(Selected)",modal.name]];
        return modal.isLevelUnlocked;
    }
    else{
        [Flurry logEvent:[NSString stringWithFormat:@"Level-%@(Locked)",modal.name]];
    }
    return NO;
}

//- (BOOL)canPerformUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender NS_AVAILABLE_IOS(6_0)
//{
//    return YES;
//}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIView *btn = (UIView*)sender;
    KKGameSceneController *nextVC = (KKGameSceneController *)[segue destinationViewController];
    KKLevelModal *modal = [self currentLevelData:btn.tag];
    if(modal){
        BOOL isLevelUnlocked = modal.isLevelUnlocked;
#ifdef ENABLE_ALL_LEVELS
        isLevelUnlocked = YES;
#endif
        if(isLevelUnlocked){
            nextVC.levelModel = [self currentLevelData:btn.tag];
            [[KKGameStateManager sharedManager] setCurrentLevel:btn.tag andStage:_currentStage];
            NSString *level = nextVC.levelModel.name;
            NSNumber *stage = [NSNumber numberWithInt:self.currentStage];
            NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[level,stage]
                                                             forKeys:@[@"level", @"stage"]];
            [Flurry logEvent:@"LevelSelect" withParameters:dict];
        }
    }

}

- (IBAction)handleButtonAction:(UIButton*)sender
{
    NSInteger stage = sender.tag;

    BOOL isLocked = [[KKGameStateManager sharedManager] isStageLocked:stage];
#ifdef ENABLE_ALL_LEVELS
    isLocked = NO;
#endif
    if(!isLocked){
        [Flurry logEvent:[NSString stringWithFormat:@"StageSelect-%d(Selected)",stage]];

        self.currentStage = sender.tag;
        
        [self hideStageSelectionDialog];
        [self loadLevelsForStage];
        
        NSNumber *stage = [NSNumber numberWithInt:self.currentStage];
        NSDictionary *dict = [NSDictionary dictionaryWithObject:stage
                                                         forKey:@[@"stage"]];
        [Flurry logEvent:@"StageSelect" withParameters:dict];
    }
    else{
        [Flurry logEvent:[NSString stringWithFormat:@"StageSelect-%d(Locked)",stage]];

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Stage Locked!"
                                                        message:@"Complete all levels in previous stage to unlock the stage"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        
        [alert show];
    }
}

- (IBAction)handleSoundSwitch:(UISwitch*)sender
{
    [[KKGameStateManager sharedManager] setSoundEnabled:sender.isOn];

    if(sender.isOn)
       [self playMusic];
    else
        [self stopMusic];
}

- (void)dealloc
{
}

@end
