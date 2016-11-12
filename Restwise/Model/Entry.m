//
//  Entry.m
//  Restwise
//
//  Created by Bogdan on 11/10/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "Entry.h"

@implementation Entry

- (id)init {
    if (self = [super init]) {
        self.date = [[NSDate alloc]init];
        self.pulse = [NSNumber numberWithInt:0];
        self.hrv = [NSNumber numberWithInt:0];
        self.sp02 = [NSNumber numberWithInt:0];
        self.weight = [NSNumber numberWithInt:0];
        self.sleep = [NSNumber numberWithInt:0];
        self.sleepHours = [NSNumber numberWithInt:0];
        self.sleepQuality = SleepQualityWorse;
        self.energy = EnergyLevelWorse;
        self.mood = MoodLevelWorse;
        self.performance = PerformanceLevelMuchWorse;
        self.appetite = AppetiteLevelNormal;
        self.illness = IllnessLevelNo;
        self.soreness = SornessLevelNo;
        self.injury = InjuryLevelNo;
        self.menstrual = MenstrualLevelNo;
        self.urineShade = UrineShadePale;
        self.comments = @"";
        
        self.sessions = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *newSession = [[NSMutableDictionary alloc] init];
        
        [newSession setObject:@0 forKey:@"activity"];
        [newSession setObject:@0 forKey:@"volume"];
        [newSession setObject:@0 forKey:@"intensity"];
        [newSession setObject:@"" forKey:@"session_type"];
        [newSession setObject:@"" forKey:@"time_of_day"];
        [newSession setObject:@"" forKey:@"venue"];
        
        [self.sessions addObject:newSession];
        
        self.activities = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
