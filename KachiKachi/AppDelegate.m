//
//  AppDelegate.m
//  KachiKachi
//
//  Created by Chandan on 08/08/2013.
//  Copyright (c) 2014 Chanddan. All rights reserved.
//

#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSString *versionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    [Flurry setAppVersion:versionString];
    [Flurry startSession:FLURRY_ID];

    CFUUIDRef uuid = CFUUIDCreate(NULL);
    //uniqueIdentifier = ( NSString*)CFUUIDCreateString(NULL, uuid);- for non- ARC
    NSString *uniqueIdentifier = ( NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));// for ARC
    CFRelease(uuid);
    [Flurry setUserID:uniqueIdentifier];
    
    [Crashlytics startWithAPIKey:@"ef1df6810a8ae85dc6971ad31a2311a71214d012"];
    
    // Override point for customization after application launch.
    _configuration = [[KKGameConfigManager alloc] init];
    _navigationController = (UINavigationController*)[self.window rootViewController];
    
    //enable preview mode
    [iRate sharedInstance].delegate = self;
    [iRate sharedInstance].appStoreID = APPSTORE_ID;
    
    //Push notification
    [[PushAppsManager sharedInstance] startPushAppsWithAppToken:@"d351895a-97db-4d1b-8af6-28e594481633" withLaunchOptions:launchOptions];
    
    return YES;
}

#pragma - Push notification -
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Notify PushApps of a successful registration.
    [[PushAppsManager sharedInstance] updatePushToken:deviceToken];
}

// Gets called when a remote notification is received while app is in the foreground.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[PushAppsManager sharedInstance] handlePushMessageOnForeground:userInfo];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    // keeps you up to date with any errors during push setup.
    [[PushAppsManager sharedInstance] updatePushError:error];
}

#pragma mark - PushAppsDelegate

- (void)pushApps:(PushAppsManager *)manager didReceiveRemoteNotification:(NSDictionary *)pushNotification whileInForeground:(BOOL)inForeground
{
    //handle push notification
}

- (void)pushApps:(PushAppsManager *)manager didUpdateUserToken:(NSString *)pushToken
{
    //handle push notification
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
     [[PushAppsManager sharedInstance] clearApplicationBadge];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark -iRate delegate - 

- (void)iRateCouldNotConnectToAppStore:(NSError *)error
{
    [Flurry logEvent:@"Rate-ConnectionError"];
}

- (void)iRateDidPromptForRating
{
    [Flurry logEvent:@"Rate-Prompted"];
}

- (void)iRateUserDidAttemptToRateApp
{
    [Flurry logEvent:@"Rate-AttemptToRate"];
}

- (void)iRateUserDidDeclineToRateApp
{
    [Flurry logEvent:@"Rate-Declined"];
}

- (void)iRateUserDidRequestReminderToRateApp
{
    [Flurry logEvent:@"Rate-RemindMeLater"];
}

- (void)iRateDidOpenAppStore
{
    [Flurry logEvent:@"Rate-OpenAppStore"];
}


@end
