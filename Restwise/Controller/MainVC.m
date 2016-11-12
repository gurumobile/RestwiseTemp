//
//  MainVC.m
//  Restwise
//
//  Created by Bogdan on 11/11/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "MainVC.h"

@interface MainVC ()

@property (nonatomic, weak) UIViewController *currentVC;

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self onLoadCurrentVC:@"EnterDataVC"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onLoadCurrentVC:(NSString *)identifier {
    self.currentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EnterDataVC"];
    self.currentVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:self.currentVC];
    [self addSubview:self.currentVC.view toView:self.containerView];
}

#pragma mark -
#pragma mark - Customize AddSubview Action...

- (void)addSubview:(UIView *)subView toView:(UIView*)parentView {
    [parentView addSubview:subView];
    
    NSDictionary * views = @{@"subView" : subView,};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subView]|"
                                                                   options:0
                                                                   metrics:0
                                                                     views:views];
    [parentView addConstraints:constraints];
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subView]|"
                                                          options:0
                                                          metrics:0
                                                            views:views];
    [parentView addConstraints:constraints];
}

- (void)cycleFromViewController:(UIViewController*)oldViewController
               toViewController:(UIViewController*)newViewController {
    [oldViewController willMoveToParentViewController:nil];
    [self addChildViewController:newViewController];
    [self addSubview:newViewController.view toView:self.containerView];
    newViewController.view.alpha = 0;
    [newViewController.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         newViewController.view.alpha = 1;
                         oldViewController.view.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [oldViewController.view removeFromSuperview];
                         [oldViewController removeFromParentViewController];
                         [newViewController didMoveToParentViewController:self];
                     }];
}

#pragma mark -
#pragma mark - Tabbar Action...

- (IBAction)onTabbarAction:(UIButton *)sender {
    UIViewController *newVC = [[UIViewController alloc] init];
    
    switch (sender.tag) {
        case 11:
            newVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EnterDataVC"];
            newVC.view.translatesAutoresizingMaskIntoConstraints = NO;
            [self cycleFromViewController:self.currentVC toViewController:newVC];
            self.currentVC = newVC;
            break;
        case 12:
            newVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ResultsVC"];
            newVC.view.translatesAutoresizingMaskIntoConstraints = NO;
            [self cycleFromViewController:self.currentVC toViewController:newVC];
            self.currentVC = newVC;
            break;
        case 13:
            newVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyAthletesVC"];
            newVC.view.translatesAutoresizingMaskIntoConstraints = NO;
            [self cycleFromViewController:self.currentVC toViewController:newVC];
            self.currentVC = newVC;
            break;
        default:
            break;
    }
}

@end
