//
//  EntryRange.m
//  Restwise
//
//  Created by Bogdan on 11/10/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "EntryRange.h"

@implementation EntryRange

- (id)init {
    if (self = [super init]) {
        self.toDate = [[NSDate alloc]init];
        
        //Two Weeks ago
        self.fromDate = [[NSDate alloc]init];
        self.score = [NSNumber numberWithInt:0];
        self.scoreExplanation = @"";
        self.chartConfig = [[ChartConfiguration alloc] init];
    }
    return self;  
}

@end
