//
//  AlertKit.m
//  Restwise
//
//  Created by Bogdan on 11/11/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "AlertKit.h"
#import "SCLAlertView.h"

@interface AlertKit ()

@end

@implementation AlertKit

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

+ (AlertKit *)sharedInstance {
    static AlertKit *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[AlertKit alloc] init];
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
