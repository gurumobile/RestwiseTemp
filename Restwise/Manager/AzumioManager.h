//
//  AzumioManager.h
//  Restwise
//
//  Created by Bogdan on 11/12/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AzumioManager : NSObject

+ (BOOL)available;
+ (void)getHeartRate;

@end
