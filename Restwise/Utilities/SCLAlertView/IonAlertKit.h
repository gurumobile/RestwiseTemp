//
//  IonAlertKit.h
//  ForumApp
//
//  Created by Ion Tiriac on 15/09/16.
//  Copyright © 2016 NZT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IonAlertKit : UIViewController

+ (IonAlertKit *)sharedInstance;

- (void)showWarning:(UIViewController *)controller title:(NSString *)title message:(NSString *)message closeButtonTitle:(NSString *)closeButtonTitle;
- (void)showError:(UIViewController *)controller title:(NSString *)title message:(NSString *)message closeButtonTitle:(NSString *)closeButtonTitle;
- (void)showNotice:(UIViewController *)controller title:(NSString *)title message:(NSString *)message closeButtonTitle:(NSString *)closeButtonTitle;
- (void)showWithDuration:(UIViewController *)controller title:(NSString *)title message:(NSString *)message;

@end