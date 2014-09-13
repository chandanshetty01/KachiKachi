//
//  KKCustomAlertViewController.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "KKCustomAlertViewController.h"
#import "ILTranslucentView.h"

@interface KKCustomAlertViewController ()
@property (weak, nonatomic) IBOutlet ILTranslucentView *alertHolderView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic,strong) completionBlkWithInteger block;
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
    
    self.alertHolderView.translucentAlpha = 1;
    self.alertHolderView.translucentStyle = UIBarStyleDefault;
    self.alertHolderView.translucentTintColor = [UIColor clearColor];
    self.alertHolderView.backgroundColor = [UIColor clearColor];
    
    self.cancelButton.tag = 0;
    [self.cancelButton addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setBackgroundImage:[self buttonImage] forState:UIControlStateNormal]
    ;
    [self.cancelButton setBackgroundImage:[self buttonImageHighlight] forState:UIControlStateHighlighted];
}

-(UIImage*)buttonImage
{
    return [[UIImage imageNamed:@"whiteButton.png"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
}

-(UIImage*)buttonImageHighlight
{
    return [[UIImage imageNamed:@"whiteButtonHighlight.png"]
            resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
}

-(void)reAdjustFrame
{
    __block CGRect alertViewFrame = self.alertHolderView.frame;
    [self.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(idx != 0){
            alertViewFrame.size.height += self.cancelButton.frame.size.height + 10;
        }
    }];
    
    self.alertHolderView.frame = alertViewFrame;
    self.alertHolderView.center = self.view.center;
    
    __block CGFloat yPos = self.alertHolderView.bounds.size.height;
    yPos = yPos - self.cancelButton.frame.size.height - 10;
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        
        CGRect frame = obj.frame;
        frame.origin.y = yPos;
        obj.frame = frame;
        
        yPos = yPos - self.cancelButton.frame.size.height - 10;
    }];
}

-(void)addButtonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    // Set the background for any states you plan to use
    [button setBackgroundImage:[self buttonImage] forState:UIControlStateNormal]
    ;
    [button setBackgroundImage:[self buttonImageHighlight] forState:UIControlStateHighlighted];
    button.titleLabel.font = self.cancelButton.titleLabel.font;
    button.backgroundColor = self.cancelButton.backgroundColor;
    [button setTitleColor:self.cancelButton.titleLabel.textColor forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.tag = [self.buttons count];
    [button addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = self.cancelButton.frame;
    [self.alertHolderView addSubview:button];
    [self.buttons addObject:button];
    [self reAdjustFrame];
}

-(void)showAlertWithTitle:(NSString*)title
                  message:(NSString*)message
              buttonTitle:(NSString*)btnTitle
             inController:(UIViewController*)controller
               completion:(completionBlkWithInteger)blk
{
    CGRect frame = self.view.frame;
    frame.origin = CGPointZero;
    self.view.frame = frame;
    [controller.view addSubview:self.view];
    [controller addChildViewController:self];
    
    self.block = blk;
    self.titleLabel.text = title;
    self.messageLabel.text = message;
    [self.cancelButton setTitle:btnTitle forState:UIControlStateNormal];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0f];
    CGRect actualFrame = self.alertHolderView.frame;
    CGRect tFrame = actualFrame;
    tFrame.origin.y = -self.alertHolderView.frame.size.height;
    self.alertHolderView.frame = tFrame;
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:.5f
                     animations:^{
                         self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:.4f];
                         self.alertHolderView.frame = actualFrame;
                     }
                     completion:^(BOOL finished) {
                         self.view.userInteractionEnabled = YES;
                     }];
}

-(void)removeViews
{
    self.block = nil;
    self.view.userInteractionEnabled = YES;
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void)removeController:(completionBlkWithInteger)blk
{
    [self.buttons removeAllObjects];
    
    CGRect alertFrame = self.alertHolderView.frame;
    alertFrame.origin.y = -self.alertHolderView.frame.size.height;
    self.view.userInteractionEnabled = NO;
    [UIView animateWithDuration:.5f
                     animations:^{
                         self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0f];
                         self.alertHolderView.frame = alertFrame;
                     }
                     completion:^(BOOL finished) {
                         if(blk)
                             blk(1);
                         [self removeViews];
                     }];
}

-(void)buttonClickAction:(UIButton*)button
{
    if(self.canDismissOnButtonPress)
        [self removeController:nil];
    
    if(self.block)
        self.block(button.tag);
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
