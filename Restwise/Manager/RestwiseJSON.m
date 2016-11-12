//
//  RestwiseJSON.m
//  Restwise
//
//  Created by Bogdan on 11/12/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "RestwiseJSON.h"
#import "JSON.h"

NSString *const JSON_DATE_FORMATTER_STRING = @"MM-dd-yyyy";
NSString *const JSON_DATE_RANGE_FORMATTER_STRING = @"yyyy-MM-dd";

NSString *const TO_DATE_SCORE = @"to_date_score";
NSString *const SCORE_EXPLANATION = @"score_explanation";
NSString *const NUM_DAYS = @"num_days";
NSString *const COOKED_DATA = @"cooked_data";
NSString *const DATE = @"date";
NSString *const LAST_DATA_DATE = @"last_data_date";
NSString *const COMMENTS = @"comments";
NSString *const SCORE = @"score";
NSString *const HRV = @"hrv";
NSString *const HRVREF = @"hrv_ref";
NSString *const SP02 = @"sp02";
NSString *const ILLNESS = @"illness";
NSString *const APPETITE = @"appetite";
NSString *const URINE_SHADE = @"urine_shade";
NSString *const PULSE = @"pulse";
NSString *const SLEEP = @"sleep";
NSString *const SLEEP_HOURS = @"sleep_hours";
NSString *const SLEEP_QUALITY = @"sleep_quality";
NSString *const WEIGHT = @"weight";
NSString *const SORENESS = @"soreness";
NSString *const INJURY = @"injury";
NSString *const MENSTRUAL = @"menstrual";
NSString *const MOOD = @"mood";
NSString *const ENERGY = @"energy";
NSString *const PERFORMANCE = @"performance";
NSString *const SESSIONS = @"sessions";
NSString *const ACTIVITIES = @"session_activity";
NSString *const LOAD = @"custom_metric";
NSString *const ERROR = @"error";
NSString *const STATUS = @"status";
NSString *const FROM_DATE = @"from_date";
NSString *const TO_DATE = @"to_date";
NSString *const STATUS_SUCCESS =@"success";
NSString *const STATUS_ERROR = @"error";
NSString *const CHART_URL = @"chart_url";
NSString *const CHART_WIDTH = @"chart_width";
NSString *const CHART_HEIGHT = @"chart_height";
NSString *const SUBMIT_JSON = @"submit_json";
NSString *const SHOW_COMPONENTS = @"show_bar";
NSString *const EMAIL = @"email";

@implementation RestwiseJSON

+ (Entry *)entryFromJSONString:(NSString *)jsonString lastBlock:(BOOL)isLastBlock {
    NSLog(@"Getting Entry for JSON: %@",jsonString);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:JSON_DATE_FORMATTER_STRING];
    NSDateFormatter *dateRangeFormatter = [[NSDateFormatter alloc] init];
    [dateRangeFormatter setDateFormat:JSON_DATE_RANGE_FORMATTER_STRING];
    NSDictionary *jsonEntry = [jsonString JSONValue];
    
    Entry *entry = [[Entry alloc] init];
    
    NSString *dateString = [jsonEntry objectForKey:DATE];
    
    if (dateString!=nil) {
        
        NSRange   dashRange       = [dateString rangeOfString:@" - "];
        NSRange   firstDashRange  = [dateString rangeOfString:@"-"];
        
        if( dashRange.location == NSNotFound )
        {
            if( firstDashRange.location == 4 )
            {
                entry.date = [dateRangeFormatter dateFromString:dateString];
            }
            else
            {
                entry.date = [dateFormatter dateFromString:dateString];
            }
        }
        else
        {
            if( isLastBlock )
            {
                entry.date = [dateRangeFormatter dateFromString:[dateString substringFromIndex:dashRange.location + 3]];
            }
            else
            {
                entry.date = [dateRangeFormatter dateFromString:[dateString substringToIndex:dashRange.location]];
            }
        }
    }
    NSString *lastDataDateString = [jsonEntry objectForKey:LAST_DATA_DATE];
    if (lastDataDateString!=nil) {
        entry.lastDataDate = [dateFormatter dateFromString:lastDataDateString];
    }
    NSString *commentsString = [jsonEntry objectForKey:COMMENTS];
    if (commentsString!=nil) {
        entry.comments = commentsString;
    }
    NSString *scoreString = [jsonEntry objectForKey:SCORE];
    if (scoreString!=nil) {
        entry.score = [NSNumber numberWithInt:[scoreString intValue]];
    }
    NSString *sp02String = [jsonEntry objectForKey:SP02];
    if (sp02String!=nil) {
        entry.sp02 = [NSNumber numberWithInt:[sp02String intValue]];
    }
    NSString *hrvString = [jsonEntry objectForKey:HRV];
    if (hrvString!=nil) {
        entry.hrv = [NSNumber numberWithInt:[hrvString intValue]];
    }
    NSString *illnessString = [jsonEntry objectForKey:ILLNESS];
    if (illnessString!=nil) {
        if ([illnessString intValue]==0){
            entry.illness = IllnessLevelNo;
        }
        else if([illnessString intValue]==1){
            entry.illness = IllnessLevelYes;
        }
    }
    NSString *appetiteString = [jsonEntry objectForKey:APPETITE];
    if (appetiteString!=nil) {
        entry.appetite = [appetiteString intValue];
    }
    NSString *urineString = [jsonEntry objectForKey:URINE_SHADE];
    if (urineString!=nil&&[urineString intValue]>0) {
        entry.urineShade = [urineString intValue]-1;
    }
    NSString *pulseString = [jsonEntry objectForKey:PULSE];
    if (pulseString!=nil) {
        entry.pulse = [NSNumber numberWithInt:[pulseString intValue]];
    }
    NSString *sleepStr = [jsonEntry objectForKey:SLEEP];
    if (sleepStr!=nil) {
        entry.sleep = [NSNumber numberWithInt:[sleepStr intValue]];
    }
    NSString *sleepHoursStr = [jsonEntry objectForKey:SLEEP_HOURS];
    if (sleepHoursStr!=nil) {
        entry.sleepHours = [NSNumber numberWithFloat:[sleepHoursStr floatValue]];
    }
    NSString *sleepQualityStr = [jsonEntry objectForKey:SLEEP_QUALITY];
    if (sleepQualityStr!=nil&&[sleepQualityStr intValue]>0) {
        entry.sleepQuality = [sleepQualityStr intValue]-1;
    }
    NSString *weightStr = [jsonEntry objectForKey:WEIGHT];
    if (weightStr!=nil) {
        entry.weight = [NSNumber numberWithFloat:[weightStr floatValue]];
    }
    NSString *sorenessStr = [jsonEntry objectForKey:SORENESS];
    if (sorenessStr!=nil) {
        if ([sorenessStr intValue]==0){
            entry.soreness = SornessLevelNo;
        }
        else if([sorenessStr intValue]==1){
            entry.soreness = SornessLevelYes;
        }
    }
    NSString *injuryStr = [jsonEntry objectForKey:INJURY];
    if (injuryStr!=nil) {
        if ([injuryStr intValue]==0){
            entry.injury = InjuryLevelNo;
        }
        else if([injuryStr intValue]==1){
            entry.injury = InjuryLevelYes;
        }
    }
    NSString *menstrualStr = [jsonEntry objectForKey:MENSTRUAL];
    if (menstrualStr!=nil) {
        if ([menstrualStr intValue]==0){
            entry.menstrual = MenstrualLevelNo;
        }
        else if([menstrualStr intValue]==1){
            entry.menstrual = MenstrualLevelYes;
        }
    }
    NSString *moodStr = [jsonEntry objectForKey:MOOD];
    if (moodStr!=nil && [moodStr intValue]>0) {
        entry.mood = [moodStr intValue]-1;
    }
    NSString *energyStr = [jsonEntry objectForKey:ENERGY];
    if (energyStr!=nil && [energyStr intValue] >0) {
        entry.energy = [energyStr intValue]-1;
    }
    NSString *performanceStr = [jsonEntry objectForKey:PERFORMANCE];
    if (performanceStr!=nil && [performanceStr intValue] >0) {
        entry.performance = [performanceStr intValue]-1;
    }
    
    NSArray *sessionArray = [jsonEntry objectForKey:SESSIONS];
    
    if( sessionArray!=nil && [sessionArray count] )
    {
        [entry.sessions removeAllObjects];
        
        for(NSDictionary *dict in sessionArray)
        {
            [entry.sessions addObject:[NSMutableDictionary dictionaryWithDictionary:dict]];
        }
    }
#if 0
    else
    {
        NSMutableDictionary *newSession = [[NSMutableDictionary alloc] init];
        
        [newSession setObject:@0 forKey:@"activity"];
        [newSession setObject:@0 forKey:@"volume"];
        [newSession setObject:@0 forKey:@"intensity"];
        [newSession setObject:@"" forKey:@"session_type"];
        [newSession setObject:@"" forKey:@"time_of_day"];
        [newSession setObject:@"" forKey:@"venue"];
        
        [entry.sessions addObject:newSession];
    }
#endif
    
    NSArray *activityArray = [jsonEntry objectForKey:ACTIVITIES];
    
    if( activityArray!=nil && [activityArray count] )
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USER_DEFAULTS_SESSIONSENABLED];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSArray         *activities = [[NSUserDefaults standardUserDefaults] arrayForKey:USER_DEFAULTS_SESSION_ACTIVITIES];
        NSMutableArray  *allActivites;
        
        if( activities )
        {
            allActivites = [[NSMutableArray alloc] init];
            [allActivites addObjectsFromArray:activities];
        }
        else
        {
            allActivites = [[NSMutableArray alloc] init];
            
            [[NSUserDefaults standardUserDefaults] setObject:allActivites forKey:USER_DEFAULTS_SESSION_ACTIVITIES];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        
        for(NSDictionary *dict in activityArray)
        {
            BOOL found = NO;
            
            for(NSDictionary *aDict in allActivites)
            {
                if( [[aDict objectForKey:@"id"] intValue] == [[dict objectForKey:@"id"] intValue] )
                    found = YES;
            }
            
            if( !found )
            {
                [allActivites addObject:dict];
                [entry.activities addObject:dict];
            }
        }
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"label" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [allActivites sortUsingDescriptors:sortDescriptors];
        
        [[NSUserDefaults standardUserDefaults] setObject:allActivites forKey:USER_DEFAULTS_SESSION_ACTIVITIES];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    NSString *statusString = [jsonEntry objectForKey:STATUS];
    if (statusString!=nil) {
        entry.status = statusString;
    }
    NSString *errorString = [jsonEntry objectForKey:ERROR];
    if (errorString!=nil) {
        entry.error = errorString;
    }
    
    return entry;
}

+ (NSString *)JSONStringFromEntry:(Entry *)entry {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:JSON_DATE_FORMATTER_STRING];
    NSMutableDictionary *jsonValue = [NSMutableDictionary dictionary];
    [jsonValue setObject:[dateFormatter stringFromDate:entry.date] forKey:DATE];
    [jsonValue setObject:[entry.pulse stringValue] forKey:PULSE];
    [jsonValue setObject:[entry.hrv stringValue] forKey:HRV];
    [jsonValue setObject:[entry.sp02 stringValue] forKey:SP02];
    
    if (entry.illness == IllnessLevelNo){
        [jsonValue setObject:@"0" forKey:ILLNESS];
    }
    else if(entry.illness == IllnessLevelYes){
        [jsonValue setObject:@"1" forKey:ILLNESS];
    }
    
    [jsonValue setObject:[[NSNumber numberWithInt:entry.appetite]stringValue] forKey:APPETITE];
    [jsonValue setObject:[[NSNumber numberWithInt:entry.urineShade+1]stringValue] forKey:URINE_SHADE];
    [jsonValue setObject:[entry.sleepHours stringValue] forKey:SLEEP_HOURS];
    [jsonValue setObject:[[NSNumber numberWithInt:entry.sleepQuality+1]stringValue] forKey:SLEEP_QUALITY];
    [jsonValue setObject:[entry.weight stringValue] forKey:WEIGHT];
    if (entry.soreness == SornessLevelNo){
        [jsonValue setObject:@"0" forKey:SORENESS];
    }
    else if(entry.soreness == SornessLevelYes){
        [jsonValue setObject:@"1" forKey:SORENESS];
    }
    if (entry.injury == InjuryLevelNo){
        [jsonValue setObject:@"0" forKey:INJURY];
    }
    else if(entry.injury == InjuryLevelYes){
        [jsonValue setObject:@"1" forKey:INJURY];
    }
    if (entry.menstrual == MenstrualLevelNo){
        [jsonValue setObject:@"0" forKey:MENSTRUAL];
    }
    else if(entry.menstrual == MenstrualLevelYes){
        [jsonValue setObject:@"1" forKey:MENSTRUAL];
    }
    
    if( [entry.sessions count] )
    {
        [jsonValue setObject:entry.sessions forKey:SESSIONS];
    }
    
    
    [jsonValue setObject:[[NSNumber numberWithInt:entry.mood+1]stringValue] forKey:MOOD];
    [jsonValue setObject:[[NSNumber numberWithInt:entry.energy+1]stringValue] forKey:ENERGY];
    [jsonValue setObject:[[NSNumber numberWithInt:entry.performance+1]stringValue] forKey:PERFORMANCE];
    [jsonValue setObject:entry.comments forKey:COMMENTS];
    
    return [jsonValue JSONRepresentation];
}

+ (EntryRange *)entryRangeFromJSONString:(NSString *)jsonString {
    NSLog(@"Getting EntryRange for JSON: %@",jsonString);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:JSON_DATE_FORMATTER_STRING];
    EntryRange *resultEntryRange = [[EntryRange alloc] init];
    NSDictionary *jsonValue = [jsonString JSONValue];
    
    //ERROR
    NSString *errorString = [jsonValue objectForKey:ERROR];
    if (errorString!=nil) {
        resultEntryRange.error = errorString;
    }
    //SCORE
    NSString *toDateString = [jsonValue objectForKey:TO_DATE_SCORE];
    if (toDateString!=nil) {
        resultEntryRange.score = [NSNumber numberWithInt:[toDateString intValue]];
    }
    NSString *scoreExplanationString = [jsonValue objectForKey:SCORE_EXPLANATION];
    if (scoreExplanationString!=nil) {
        resultEntryRange.scoreExplanation = scoreExplanationString;
    }
    //Entries
    NSMutableArray *entries = [[NSMutableArray alloc]init];
    NSArray *jsonEntries = [jsonValue objectForKey:COOKED_DATA];
    if (jsonEntries!=nil) {
        for (NSDictionary *jsonEntry in jsonEntries) {
            BOOL isLastBlock = [jsonEntries indexOfObject:jsonEntry]==([jsonEntries count]-1);
            
            Entry *entry = [RestwiseJSON entryFromJSONString:[jsonEntry JSONRepresentation] lastBlock:isLastBlock];
            if ([jsonEntries indexOfObject:jsonEntry]==0){
                resultEntryRange.fromDate = [entry.date copy];
            }
            else if (isLastBlock){
                resultEntryRange.toDate = [entry.date copy];
            }
            [entries addObject:entry];
        }
    }
    resultEntryRange.entries = entries;
    
    NSString *chartURLString = [jsonValue objectForKey:CHART_URL];
    if (chartURLString!=nil) {
        resultEntryRange.chartURLString = chartURLString;
    }
    NSString *chartWidthString = [jsonValue objectForKey:CHART_WIDTH];
    if (chartWidthString!=nil) {
        resultEntryRange.chartWidth = [NSNumber numberWithInt:[chartWidthString intValue]];
    }
    NSString *chartHeightString = [jsonValue objectForKey:CHART_HEIGHT];
    if (chartHeightString!=nil) {
        resultEntryRange.chartHeight = [NSNumber numberWithInt:[chartHeightString intValue]];
    }

    return resultEntryRange;
}

@end
