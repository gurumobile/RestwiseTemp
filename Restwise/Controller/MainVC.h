//
//  MainVC.h
//  Restwise
//
//  Created by Bogdan on 11/11/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *containerView;

- (IBAction)onTabbarAction:(UIButton *)sender;

@end
