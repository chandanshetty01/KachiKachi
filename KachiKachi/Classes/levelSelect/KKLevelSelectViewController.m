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
@property(nonatomic,strong) NSMutableArray *levels;

@end

@implementation KKLevelSelectViewController

- (void)viewDidLoad
{    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    
    [self loadLevelsForStage];
}

-(void)loadLevelsForStage
{
    self.levels = [[KKGameStateManager sharedManager] levels];
    [self.collectionView reloadData];
}

- (IBAction)backButtonAction:(id)sender
{
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

    [Flurry logEvent:@"BackButton - Level Select"];
    AppDelegate *appdelegate = APP_DELEGATE;
    [appdelegate.navigationController popViewControllerAnimated:YES];
}

-(KKLevelModal*)currentLevelData:(NSInteger)levelID
{
    return [self.levels objectAtIndex:levelID];
}

#pragma mark - UICollectionView methods -


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.levels.count;
}

-(void)updateStarsView:(KKCollectionViewCell*)cell andModal:(KKLevelModal*)levelModal
{
    if(levelModal.noOfStars > 0){
        cell.starDisplayView.hidden = NO;
        if(levelModal.noOfStars == 3){
            cell.star1ImageView.hidden = NO;
            cell.star2ImageView.hidden = NO;
            cell.star3ImageView.hidden = NO;
        }
        else if(levelModal.noOfStars == 2){
            cell.star1ImageView.hidden = YES;
            cell.star2ImageView.hidden = NO;
            cell.star3ImageView.hidden = NO;
        }
        else if(levelModal.noOfStars == 1){
            cell.star1ImageView.hidden = YES;
            cell.star2ImageView.hidden = NO;
            cell.star3ImageView.hidden = YES;
        }
        else{
            cell.starDisplayView.hidden = YES;
        }
    }
    else{
        cell.starDisplayView.hidden = YES;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)inCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"collectionViewCell";
    KKCollectionViewCell *cell = [inCollectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.tag = [indexPath row];
    KKLevelModal *levelModel = [self currentLevelData:cell.tag];
    [cell.menuImage setImage:[UIImage imageNamed:levelModel.menuIconImage]];
    cell.menuImage.contentMode = UIViewContentModeScaleAspectFit;
    [self updateStarsView:cell andModal:levelModel];
    
    if(levelModel.isLevelUnlocked){
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
    [[SoundManager sharedManager] playSound:@"tap" looping:NO];

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
            [KKGameStateManager sharedManager].currentLevel = modal.levelID;
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
