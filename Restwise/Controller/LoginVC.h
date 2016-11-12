//
//  LoginVC.h
//  Restwise
//
//  Created by Bogdan on 11/10/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@protocol LoginControllerDelegate <NSObject>

- (void)logedIn;
- (void)cancelLogin;

@end

@interface LoginVC : UIViewController <MBProgressHUDDelegate> {
    MBProgressHUD *HUDView;
}

@property (weak, nonatomic) IBOutlet UIView *subView;

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (nonatomic, assign) id<LoginControllerDelegate> delegate;

- (IBAction)onLogin:(id)sender;
- (IBAction)onForgotPassword:(id)sender;
- (IBAction)onSubscribe:(id)sender;

@end
