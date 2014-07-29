//
//  AdViewController.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "iAdViewController.h"

@interface iAdViewController ()
@end

@implementation iAdViewController

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
    
    // Initialize the banner at the bottom of the screen.
    self.adBanner = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
    [self.adBanner setBackgroundColor:[UIColor clearColor]];
    self.adBanner.delegate = self;
    [self.view addSubview: self.adBanner];
}

- (void)dealloc {
    _adBanner.delegate = nil;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}


#pragma mark Ad banner implementation

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [Flurry logEvent:@"adRecieved"];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [Flurry logEvent:@"failedToRecieveAd"];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(bannerViewActionShouldBegin:willLeaveApplication:)])
        return [self.delegate bannerViewActionShouldBegin:banner willLeaveApplication:willLeave];
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(bannerViewActionDidFinish:)])
        [self.delegate bannerViewActionDidFinish:banner];
}

@end
