//
//  AppDelegate.m
//  Restwise
//
//  Created by Bogdan on 11/10/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "AppDelegate.h"
#import "IQKeyboardManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    
    NSDictionary	*appDefaults	= [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithBool:NO], USER_DEFAULTS_SESSIONSENABLED,
                                       nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
//        [_window addSubview:tabController.view];
    
//    UIImage *tabbarImage = [UIImage imageNamed:@"footer.iphone.png"];
    
//    [[UINavigationBar appearance] setBackgroundImage:tabbarImage forBarMetrics:UIBarMetricsDefault];
//    [[UITabBar appearance] setBackgroundImage:tabbarImage];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.restwise.Restwise.didBecomeActive" object:nil userInfo:nil];
    
    [self submitOfflineEntries];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if( [[url scheme] isEqualToString:@"Restwise"] )
    {
        NSString *urlString = [url absoluteString];
        
        NSRange heartRateRange = [urlString rangeOfString:@"heartrate="];
        
        if( heartRateRange.location != NSNotFound )
        {
            NSString *heartRateStr = [urlString substringFromIndex:heartRateRange.location + 10];
            
            NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:heartRateStr, @"heartRate", nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.restwise.Restwise.updateHeartRate" object:results];
        }
    }
    
    return YES;
}

#pragma mark -
#pragma mark - Submit Offline...

-(void) submitOfflineEntries{
    int offlineCount = [[RestwiseManager sharedRestwiseManager] hasOfflineEntires];
    
    if (offlineCount>0) {
//        tabController.selectedIndex=0;
        
        if (initialOfflineCount==0) {
            initialOfflineCount = offlineCount;
        }
        
        if (hudView == nil) {
            hudView = [[MBProgressHUD alloc] initWithView:_window];
            hudView.delegate = self;
            hudView.labelText = @"Submitting Saved Entries";
            hudView.mode=MBProgressHUDModeDeterminate;
            hudView.taskInProgress = YES;
            hudView.progress=0;
            
            [_window addSubview:hudView];
            [hudView show:true];
        }
        
        //update progress
        hudView.progress = ((float)initialOfflineCount-(float)offlineCount)/(float)initialOfflineCount;
        //TODO thread
        [[RestwiseManager sharedRestwiseManager] loadOfflineEntries:self];
    } else {
        initialOfflineCount = 0;
        [hudView hide:YES];
    }
}

/*
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    NSInteger rights = [RestwiseManager getUserRights];
    
    if( viewController == [tabBarController.viewControllers objectAtIndex:2]  )
    {
        if( (rights == 4) || (rights == 7) || (rights == 15) || (rights == 23) )
        {
            return YES;
        }
        else
        {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Restwise" message:@"“My Athletes” tab is available only for Coach accounts." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [alert show];
            
            return NO;
        }
    }
    else if( viewController == [tabBarController.viewControllers objectAtIndex:1] )
    {
        if( (rights == 2) || (rights == 3) || (rights == 7) || (rights == 15) || (rights == 23))
        {
            return YES;
        }
        else
        {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Restwise" message:@"“Results” tab is available only for Athlete accounts." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [alert show];
            
            return NO;
        }
    }
    else if( viewController == [tabBarController.viewControllers objectAtIndex:0] )
    {
        if( (rights == 1 || rights == 2) || (rights == 3) || (rights == 7) || (rights == 15) || (rights == 23))
        {
            return YES;
        }
        else
        {
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Restwise" message:@"“Enter Data” tab is available only for Athlete accounts." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
            [alert show];
            
            return NO;
        }
    }
    
    return YES;
}
*/

- (void)loginSuccessful {
    [self submitOfflineEntries];
}

- (void)loginFailed {
    [RestwiseManager sharedRestwiseManager].previousSession = [RestwiseManager sharedRestwiseManager].session;
    [self requiresLogin];
}

- (void)requiresLogin {
    [hudView hide:YES];
    
    LoginVC *loginView = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
    loginView.delegate = self;
//    [tabController presentModalViewController:loginView animated:YES];
}

-(void) loggingIn{
    
}

- (void) logedIn{
//    [tabController dismissModalViewControllerAnimated:YES];
    [self submitOfflineEntries];
}
- (void) cancelLogin{
//    [tabController dismissModalViewControllerAnimated:YES];
}

-(void) didEnterEntry:(Entry *)entry{
    [RestwiseManager sharedRestwiseManager].loadingOfflineEntires = NO;
    [RestwiseManager sharedRestwiseManager].previousSession = nil;
    [self submitOfflineEntries];
}

-(void) didErrorEnteringEntry:(NSError *)error{
    [RestwiseManager sharedRestwiseManager].loadingOfflineEntires = NO;
    [RestwiseManager sharedRestwiseManager].previousSession = nil;
    
    [hudView hide:NO];
    NSString *errorMsg = nil;
    
    if ([[error domain] isEqualToString:RESTWISE_ERROR_VALIDATION]) {
        NSString *errorString = [[error userInfo] objectForKey:ERROR];
        NSDate *date = [[error userInfo] objectForKey:RESTWISE_ERROR_VALIDATION_DATE];
        if (date != nil) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEE, MMM d, yyyy"];
            errorMsg = [NSString stringWithFormat:@"Error submitting for %@. %@. Please fix and resubmit.",[dateFormatter stringFromDate:date],errorString];
        }
        else {
            errorMsg = [NSString stringWithFormat:@"Error submitting saved entry. %@. Please fix and resubmit.",errorString];
        }
        
        
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error submitting saved entry." message:errorMsg delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [hudView removeFromSuperview];
    hudView = nil;
}

@end
