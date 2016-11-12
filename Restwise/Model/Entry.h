//
//  Entry.h
//  Restwise
//
//  Created by Bogdan on 11/10/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SleepQualityWorse = 0, SleepQualityNormal=1, SleepQualityBetter=2
} SleepQuality;

typedef enum {
    EnergyLevelWorse = 0, EnergyLevelNormal=1, EnergyLevelBetter=2
} EnergyLevel;

typedef enum {
    MoodLevelWorse = 0, MoodLevelNormal=1, MoodLevelBetter=2
} MoodLevel;

typedef enum {
    PerformanceLevelMuchWorse = 0,PerformanceLevelWorse=1, PerformanceLevelNormal=2, PerformanceLevelBetter=3, PerformanceLevelMuchBetter=4, PerformanceLevelRestDay = 5
} PerformanceLevel;

typedef enum {
    AppetiteLevelLessThanNormal=0, AppetiteLevelNormal = 1
} AppetiteLevel;

typedef enum {
    IllnessLevelNo = 1, IllnessLevelYes=0
} IllnessLevel;

typedef enum {
    SornessLevelNo = 1, SornessLevelYes=0
} SornessLevel;

typedef enum {
    InjuryLevelNo = 1, InjuryLevelYes=0
} InjuryLevel;

typedef enum {
    UrineShadeDark=0 , UrineShadeYellow=1,UrineShadePale = 2
} UrineShade;

typedef enum {
    MenstrualLevelNo = 1, MenstrualLevelYes=0
} MenstrualLevel;

@interface Entry : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *lastDataDate;
@property (nonatomic, strong) NSNumber *pulse;
@property (nonatomic, strong) NSNumber *hrv;
@property (nonatomic, strong) NSNumber *sp02;
@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) NSNumber *sleep;
@property (nonatomic, strong) NSNumber *sleepHours;
@property SleepQuality sleepQuality;
@property EnergyLevel energy;
@property MoodLevel mood;
@property PerformanceLevel performance;
@property AppetiteLevel appetite;
@property IllnessLevel illness;
@property SornessLevel soreness;
@property InjuryLevel injury;
@property MenstrualLevel menstrual;
@property UrineShade urineShade;
@property (nonatomic, strong) NSString *comments;
@property (nonatomic, strong) NSNumber *score;
@property (nonatomic, strong) NSString *error;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSMutableArray *sessions;
@property (nonatomic, strong) NSMutableArray *activities;

@end
