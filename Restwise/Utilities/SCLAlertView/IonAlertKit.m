//
//  IonAlertKit.m
//  ForumApp
//
//  Created by Ion Tiriac on 15/09/16.
//  Copyright © 2016 NZT. All rights reserved.
//

#import "IonAlertKit.h"
#import "SCLAlertView.h"

@interface IonAlertKit ()

@end

@implementation IonAlertKit

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
#pragma mark - Shared Instance...

+ (IonAlertKit *)sharedInstance {
    static IonAlertKit *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[IonAlertKit alloc] init];
    });
    return sharedManager;
}

#pragma mark -
#pragma mark - Alert Action...

- (void)showWarning:(UIViewController *)controller title:(NSString *)title message:(NSString *)message closeButtonTitle:(NSString *)closeButtonTitle {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    [alert showWarning:controller title:title subTitle:message closeButtonTitle:closeButtonTitle duration:0.0f];
}

- (void)showError:(UIViewController *)controller title:(NSString *)title message:(NSString *)message closeButtonTitle:(NSString *)closeButtonTitle {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    [alert showError:controller title:title subTitle:message closeButtonTitle:@"OK" duration:0.0f];
}

- (void)showNotice:(UIViewController *)controller title:(NSString *)title message:(NSString *)message closeButtonTitle:(NSString *)closeButtonTitle {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    [alert showNotice:controller title:title subTitle:message closeButtonTitle:@"OK" duration:0.0f];
}

- (void)showWithDuration:(UIViewController *)controller title:(NSString *)title message:(NSString *)message {
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    [alert showNotice:controller title:title subTitle:message closeButtonTitle:nil duration:2.0f];
}

@end