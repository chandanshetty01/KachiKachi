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

@end

@implementation KKLevelSelectViewController

- (void)viewDidLoad
{    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
    
    self.levelModals = [NSMutableArray array];
    
    NSMutableDictionary *levels = [[KKGameConfigManager sharedManager] getAllLevels:self.currentStage];
    
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
    
    [self playMusic];
}

-(void)playMusic
{
    [[SoundManager sharedManager] playMusic:@"track1" looping:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backButtonAction:(id)sender {
    AppDelegate *appdelegate = APP_DELEGATE;
    [appdelegate.navigationController popViewControllerAnimated:YES];
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
    
    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UIView *btn = (UIView*)sender;
    KKGameSceneController *nextVC = (KKGameSceneController *)[segue destinationViewController];
    nextVC.levelModel = [self currentLevelData:btn.tag];
    [[KKGameStateManager sharedManager] setCurrentLevel:btn.tag andStage:_currentStage];
    
    
    NSNumber *level = [NSNumber numberWithInt:btn.tag];
    NSNumber *stage = [NSNumber numberWithInt:self.currentStage];
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[level,stage]
                                                     forKeys:@[@"level", @"stage"]];
    [Flurry logEvent:@"LevelSelect" withParameters:dict];
}

- (void)dealloc
{
}

@end
