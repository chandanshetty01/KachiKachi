//
//  AdViewController.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <iAd/ADBannerView.h>

@protocol iAdViewControllerDelegates;

@interface iAdViewController : UIViewController <ADBannerViewDelegate>

@property(nonatomic, strong) ADBannerView *adBanner;
@property(nonatomic, weak) id<iAdViewControllerDelegates> delegate;

@end

@protocol iAdViewControllerDelegates <NSObject>

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave;
- (void)bannerViewActionDidFinish:(ADBannerView *)banner;

@end