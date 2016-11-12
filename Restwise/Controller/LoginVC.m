//
//  LoginVC.m
//  Restwise
//
//  Created by Bogdan on 11/10/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC ()

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self onInitialize:20.0 borderWidth:1.5];
}

#pragma mark -
#pragma makr - Initialize...

- (void)onInitialize:(CGFloat)radius borderWidth:(CGFloat)borderWidth {
    self.subView.alpha = 0.0;
    
    self.emailField.text = @"";
    self.passwordField.text = @"";
    
    //Placeholder...
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email Address" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"******" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.emailField.layer.cornerRadius = radius;
    self.passwordField.layer.cornerRadius = radius;
    self.loginBtn.layer.cornerRadius = radius;
    
    self.emailField.layer.borderWidth = borderWidth;
    self.passwordField.layer.borderWidth = borderWidth;
    self.loginBtn.layer.borderWidth = borderWidth;
    
    self.emailField.layer.borderColor = [UIColor whiteColor].CGColor;
    self.passwordField.layer.borderColor = [UIColor whiteColor].CGColor;
    self.loginBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.subView.alpha = 1.0;
}

#pragma mark - 
#pragma mark - Actions...

- (IBAction)onLogin:(id)sender {
    if (self.emailField.text == nil || self.passwordField.text == nil || self.emailField.text.length == 0 || self.passwordField.text.length == 0) {
        [[AlertKit sharedInstance] showError:self title:@"Error!" message:@"Email and Password cannot be blank." closeButtonTitle:@"OK"];
    } else {
        if (HUDView == nil) {
            HUDView = [[MBProgressHUD alloc] initWithView:self.view];
            
            HUDView.delegate = self;
            HUDView.labelText = @"Logging In";
            [self.view addSubview:HUDView];
            
            [HUDView show:YES];
        }
    }
    
    
//    [self performSegueWithIdentifier:@"toMain" sender:nil];
}

- (IBAction)onForgotPassword:(id)sender {
}

- (IBAction)onSubscribe:(id)sender {
}

#pragma mark - 
#pragma mark - Login Status...

- (void)loginSuccessful {
    [HUDView hide:true];
    [_delegate logedIn];
}

- (void)loginFailed {
    [HUDView hide:true];
}

- (void)didEmailLogin {
    [HUDView hide:true];
    
    [[AlertKit sharedInstance] showError:self title:@"Email sent" message:nil closeButtonTitle:@"OK"];
}

- (void)didErrorEmailLogin:(NSError *)error {
    [HUDView hide:true];
    
    [[AlertKit sharedInstance]showError:self title:@"Error" message:@"Error sending email" closeButtonTitle:@"OK"];
}









@end
