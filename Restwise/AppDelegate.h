//
//  AppDelegate.h
//  Restwise
//
//  Created by Bogdan on 11/10/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestwiseManager.h"
#import "RestwiseJSON.h"
#import "LoginVC.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, RestwiseManagerDelegate, RestwiseManagerLoginDelegate, LoginControllerDelegate, RestwiseManagerEnterEntryDelegate, MBProgressHUDDelegate> {
    MBProgressHUD *hudView;
    int initialOfflineCount;
}

@property (strong, nonatomic) UIWindow *window;

@end

