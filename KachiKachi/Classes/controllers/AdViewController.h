//
//  AdViewController.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "GADBannerViewDelegate.h"
#import "GADBannerView.h"
#import "GADRequest.h"


#define kSampleAdUnitID @"ca-app-pub-8550503434164212/5853012552"

@class GADBannerView;
@class GADRequest;

@interface AdViewController : UIViewController<GADBannerViewDelegate>

@property(nonatomic, strong) GADBannerView *adBanner;

@end
