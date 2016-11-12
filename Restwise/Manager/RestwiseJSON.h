//
//  RestwiseJSON.h
//  Restwise
//
//  Created by Bogdan on 11/12/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entry.h"
#import "EntryRange.h"
#import "RestwiseManager.h"

extern NSString *const JSON_DATE_FORMATTER_STRING;
extern NSString *const JSON_DATE_RANGE_FORMATTER_STRING;
extern NSString *const TO_DATE_SCORE;
extern NSString *const SCORE_EXPLANATION;
extern NSString *const NUM_DAYS;
extern NSString *const COOKED_DATA;
extern NSString *const DATE;
extern NSString *const LAST_DATA_DATE;
extern NSString *const COMMENTS;
extern NSString *const SESSIONS;
extern NSString *const ACTIVITIES;
extern NSString *const SCORE;
extern NSString *const HRV;
extern NSString *const HRVREF;
extern NSString *const SP02;
extern NSString *const ILLNESS;
extern NSString *const APPETITE;
extern NSString *const URINE_SHADE;
extern NSString *const PULSE;
extern NSString *const SLEEP;
extern NSString *const SLEEP_HOURS;
extern NSString *const SLEEP_QUALITY;
extern NSString *const WEIGHT;
extern NSString *const SORENESS;
extern NSString *const INJURY;
extern NSString *const MENSTRUAL;
extern NSString *const MOOD;
extern NSString *const ENERGY;
extern NSString *const PERFORMANCE;
extern NSString *const LOAD;
extern NSString *const ERROR;
extern NSString *const STATUS;
extern NSString *const FROM_DATE;
extern NSString *const TO_DATE;
extern NSString *const STATUS_SUCCESS;
extern NSString *const STATUS_ERROR;
extern NSString *const CHART_URL;
extern NSString *const CHART_WIDTH;
extern NSString *const CHART_HEIGHT;
extern NSString *const SUBMIT_JSON;
extern NSString *const SHOW_COMPONENTS;
extern NSString *const EMAIL;

@interface RestwiseJSON : NSObject

/*
 Gets an Entry from a json string
 */
+(Entry *) entryFromJSONString:(NSString *)jsonString lastBlock:(BOOL)isLastBlock;

/*
 Gets a JSON string representation of an entry
 */
+(NSString *) JSONStringFromEntry:(Entry *)entry;

/*
 Get an EntryRange from a json string
 */
+(EntryRange *) entryRangeFromJSONString:(NSString *)jsonString;

@end
