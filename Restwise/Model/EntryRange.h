//
//  EntryRange.h
//  Restwise
//
//  Created by Bogdan on 11/10/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChartConfiguration.h"

@interface EntryRange : NSObject

@property (nonatomic, strong) NSDate *fromDate;
@property (nonatomic, strong) NSDate *toDate;
@property (nonatomic, strong) NSArray *entries;
@property (nonatomic, strong) NSNumber *score;
@property (nonatomic, strong) NSString *scoreExplanation;
@property (nonatomic, strong) NSString *error;
@property (nonatomic, strong) NSString *chartURLString;
@property (nonatomic, strong) NSNumber *chartWidth;
@property (nonatomic, strong) NSNumber *chartHeight;
@property (nonatomic, strong) ChartConfiguration *chartConfig;

@end
