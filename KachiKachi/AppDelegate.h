//
//  AppDelegate.h
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKGameConfigManager.h"
#import "iRate.h"
#import <PushApps/PushApps.h>
#import "AppsFlyerTracker.h"

#define APP_DELEGATE (AppDelegate *)[[UIApplication sharedApplication] delegate]


@interface AppDelegate : UIResponder <UIApplicationDelegate,iRateDelegate,PushAppsDelegate,AppsFlyerTrackerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic,readonly) KKGameConfigManager *configuration;
@property  (nonatomic,strong) UINavigationController *navigationController;

@end
