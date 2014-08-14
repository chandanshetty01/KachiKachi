//
//  KKCustomAlertViewController.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "KKCustomAlertViewController.h"

@interface KKCustomAlertViewController ()
@property (weak, nonatomic) IBOutlet UIView *alertHolderView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic,strong) completionBlk block;
@property(nonatomic,strong) NSMutableArray *buttons;
@end

@implementation KKCustomAlertViewController

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
    
    self.canDismissOnButtonPress = YES;
    
    self.buttons = [NSMutableArray array];
    [self.buttons addObject:self.cancelButton];
    
    self.cancelButton.tag = 0;
    [self.cancelButton addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)showAlertWithTitle:(NSString*)title message:(NSString*)message inController:(UIViewController*)controller completion:(completionBlk)blk
{
    [controller.view addSubview:self.view];
    [controller addChildViewController:self];
    self.block = blk;
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0f];
    [UIView animateWithDuration:.5f
                     animations:^{
                         self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

-(void)removeController
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)buttonClickAction:(UIButton*)button
{
    if(self.canDismissOnButtonPress)
        [self removeController];
    
    if(self.block)
        self.block(button.tag);
}

-(void)addButtonWithTitle:(NSString *)title
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
