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

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation KKLevelSelectViewController

- (void)viewDidLoad
{    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

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
        levelModel.stageID =  self.currentStage;
        [self.levelModals addObject:levelModel];
    }];
    
    [self.collectionView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self loadLevelsForStage];
}

- (IBAction)backButtonAction:(id)sender
{
    [Flurry logEvent:@"BackButton - Level Select"];
    AppDelegate *appdelegate = APP_DELEGATE;
    [appdelegate.navigationController popViewControllerAnimated:YES];
}

-(KKLevelModal*)currentLevelData:(NSInteger)levelID
{
    NSMutableDictionary *levelDict = [[KKGameStateManager sharedManager] gameData:levelID stage:self.currentStage];
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
        levelModel.stageID =  self.currentStage;
        return levelModel;
    }
    else
    {
        KKLevelModal *levelModel = nil;
        levelModel = [[KKLevelModal alloc] initWithDictionary:levelDict];
        levelModel.levelID = levelID;
        levelModel.stageID =  self.currentStage;
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
        return modal.isLevelUnlocked;
    }
    else{
        [Flurry logEvent:[NSString stringWithFormat:@"Level-%@(Locked)",modal.name]];
    }
    return NO;
}

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
            [[KKGameStateManager sharedManager] setCurrentLevel:btn.tag andStage:self.currentStage];
        }
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
}

@end
