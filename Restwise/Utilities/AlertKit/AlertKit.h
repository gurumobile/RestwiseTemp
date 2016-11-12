//
//  AlertKit.h
//  Restwise
//
//  Created by Bogdan on 11/11/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertKit : UIViewController

+ (AlertKit *)sharedInstance;

- (void)showWarning:(UIViewController *)controller title:(NSString *)title message:(NSString *)message closeButtonTitle:(NSString *)closeButtonTitle;
- (void)showError:(UIViewController *)controller title:(NSString *)title message:(NSString *)message closeButtonTitle:(NSString *)closeButtonTitle;
- (void)showNotice:(UIViewController *)controller title:(NSString *)title message:(NSString *)message closeButtonTitle:(NSString *)closeButtonTitle;
- (void)showWithDuration:(UIViewController *)controller title:(NSString *)title message:(NSString *)message;

@end
