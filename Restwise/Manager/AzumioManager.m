//
//  AzumioManager.m
//  Restwise
//
//  Created by Bogdan on 11/12/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "AzumioManager.h"

@implementation AzumioManager

+ (BOOL)available
{
    NSURL *ihrUrl = [NSURL URLWithString:@"instantheartrate://?callback=Restwise:?heartrate=!HR!"];
    
    return [[UIApplication sharedApplication] canOpenURL:ihrUrl];
}

+ (void)getHeartRate
{
    NSURL *ihrUrl = [NSURL URLWithString:@"instantheartrate://?callback=Restwise:?heartrate=!HR!"];
    
    [[UIApplication sharedApplication] openURL:ihrUrl];
}

@end
