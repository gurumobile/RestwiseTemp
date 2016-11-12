//
//  ChartConfiguration.m
//  Restwise
//
//  Created by Bogdan on 11/10/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "ChartConfiguration.h"

@implementation ChartConfiguration

- (id)copyWithZone:(NSZone *)zone {
    ChartConfiguration *copy = [[ChartConfiguration alloc] init];
    
    copy.sp02 = self.sp02;
    copy.illness = self.illness;
    copy.appetite = self.appetite;
    copy.urine_shade = self.urine_shade;
    copy.pulse = self.pulse;
    copy.sleep = self.sleep;
    copy.weight = self.weight;
    copy.soreness = self.soreness;
    copy.mood = self.mood;
    copy.energy = self.energy;
    copy.performance = self.performance;
    copy.load = self.load;
    copy.hrv = self.hrv;
    copy.hrvRef = self.hrvRef;
    copy.chartComponents = self.chartComponents;
    
    return copy;
}

@end
