//
//  RestwiseManager.m
//  Restwise
//
//  Created by Bogdan on 11/12/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "RestwiseManager.h"
#import "RestwiseJSON.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import "JSON.h"

static RestwiseManager *sharedManager = nil;

NSString *const USER_DEFAULTS_USERNAME_KEY = @"RestwiseUsername";
NSString *const USER_DEFAULTS_PASSWORD_KEY = @"RestwisePassword";
NSString *const USER_DEFAULTS_OFFLINE_ENTRY_KEY = @"RestwiseOfflineEntryArray";
NSString *const RESTWISE_ERROR_VALIDATION = @"RestwiseValidationError";
NSString *const RESTWISE_ERROR_VALIDATION_DATE = @"RestwiseValidationErrorDate";
NSString *const USER_DEFAULTS_SEX_KEY = @"RestwiseSex";
NSString *const USER_DEFAULTS_RIGHTS_KEY = @"RestwiseRights";
NSString *const USER_DEFAULTS_SESSION_ACTIVITIES = @"RestwiseSessionActivities";
NSString *const USER_DEFAULTS_SESSIONSENABLED = @"RestwiseSessionHasSessions";

@implementation RestwiseManager

@synthesize session, previousSession, loadingOfflineEntires;

+ (RestwiseManager *)sharedRestwiseManager {
    @synchronized(self){
        if (sharedManager == nil) {
            sharedManager = [[RestwiseManager alloc]init];
        }
    }
    return sharedManager;
}

- (id)init {
    if ((self = [super init])) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:JSON_DATE_FORMATTER_STRING];
    }
    return self;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedManager == nil) {
            sharedManager = [super allocWithZone:zone];
            return sharedManager;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark -
#pragma mark -

+(NSDateComponents *)getDataComponents:(NSDate *)date{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
//    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    unsigned unitFlags = NSCalendarUnitDay | NSCalendarUnitDay | NSCalendarUnitDay;
    
    NSDateComponents* comp = [calendar components:unitFlags fromDate:date];
    return comp;
}

+ (BOOL)isSameDay:(NSDate*)date1 and:(NSDate*)date2 {
    if( !date2) return NO;
    NSDateComponents* comp1 = [RestwiseManager getDataComponents:date1];
    NSDateComponents* comp2 = [RestwiseManager getDataComponents:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

+ (NSInteger)getUserRights
{
    NSUserDefaults  *defaults   = [NSUserDefaults standardUserDefaults];
    
    NSString *username = [defaults stringForKey:USER_DEFAULTS_USERNAME_KEY];
    NSString *password = [defaults stringForKey:USER_DEFAULTS_PASSWORD_KEY];
    if (username !=nil && password != nil)
    {
        
        
        NSInteger       rights      = [[defaults stringForKey:USER_DEFAULTS_RIGHTS_KEY] intValue];
        
        return rights;
    }
    else
    {
        return 3;
    }
}

+ (BOOL)isUserMale {
    NSUserDefaults  *defaults   = [NSUserDefaults standardUserDefaults];
    NSString        *sex        = [defaults stringForKey:USER_DEFAULTS_SEX_KEY];
    
    if( sex && [sex isEqualToString:@"male"] )
        return YES;
    
    return NO;
}

+ (BOOL)isPreviousDayTheLastEntered:(Entry*)entry{
    if (![RestwiseManager hasInternetConnection]) {
        return NO;
    }
    
    NSDate *previousDay = [[NSDate alloc] initWithTimeInterval:-(60*60*24) sinceDate:entry.date];
    
    BOOL returnVal = [RestwiseManager isSameDay:previousDay and:entry.lastDataDate];
    
    return returnVal;
}

+ (NSComparisonResult)compareDate:(NSDate *)date1 withDate:(NSDate *)date2 {
    NSDateComponents* comp1 = [RestwiseManager getDataComponents:date1];
    NSDateComponents* comp2 = [RestwiseManager getDataComponents:date2];
    
    if ([comp1 year] < [comp2 year]) {
        return NSOrderedAscending;
    }
    else if ([comp1 year] > [comp2 year]) {
        return NSOrderedDescending;
    }
    else {
        if ([comp1 month] < [comp2 month]) {
            return NSOrderedAscending;
        }
        else if ([comp1 month] > [comp2 month]) {
            return NSOrderedDescending;
        }
        else {
            if ([comp1 day] < [comp2 day]) {
                return NSOrderedAscending;
            }
            else if ([comp1 day] > [comp2 day]) {
                return NSOrderedDescending;
            }
            else {
                return NSOrderedSame;
            }
            
        }
        
    }
    
}

- (BOOL) ensureLogin:(id)delegate {
    if ([self checkCookieExistance]) {
        return YES;
    }
    else if(self.session != nil && ![RestwiseManager hasInternetConnection]){
        return YES;
    }
    else {
        //Check user defaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults stringForKey:USER_DEFAULTS_USERNAME_KEY];
        NSString *password = [defaults stringForKey:USER_DEFAULTS_PASSWORD_KEY];
        if (username !=nil && password !=nil) {
            [delegate loggingIn];
            [[RestwiseManager sharedRestwiseManager] logInWithUsername:username password:password delegate:delegate];
            return NO;
        }
    }
    
    [delegate requiresLogin];
    return NO;
}

- (NSString *)getCurrentUsername {
    if(self.session.username != nil){
        return self.session.username;
    }
    else{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        return [defaults stringForKey:USER_DEFAULTS_USERNAME_KEY];
    }
}

- (void) logInWithUsername:(NSString *)username password:(NSString *)password delegate:(id) delegate {
    if (loginConnection != nil) {
        return;
    }
    NSLog(@"Logging In");
    
    self.session = [[RestwiseSession alloc] init];
    
    self.session.username = username;
    self.session.password = password;
    
    if (![RestwiseManager hasInternetConnection]) {
        [delegate performSelectorOnMainThread:@selector(loginSuccessful) withObject:nil waitUntilDone:NO];
    }
    else{
        loginDelegate = delegate;
        
        NSString *loginBodyFormatString = @"username=%@&password=%@&get_auth_token=1";
#if 1
        NSString *newPassword = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                      (CFStringRef)password,
                                                                                                      NULL,
                                                                                                      CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                                                      kCFStringEncodingUTF8));
#endif
        //NSLog(@"%@", username);
        //NSLog(@"%@", newPassword);
        
        NSString *bodyString = [NSString stringWithFormat:loginBodyFormatString,username,newPassword];
        
        NSURL *loginURL = [self getURL:@"login.pfm"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:loginURL];

        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[bodyString dataUsingEncoding:NSISOLatin1StringEncoding]];
        
        loginConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username forKey:USER_DEFAULTS_USERNAME_KEY];
    [defaults setObject:password forKey:USER_DEFAULTS_PASSWORD_KEY];
    [defaults setBool:NO forKey:USER_DEFAULTS_SESSIONSENABLED];
    [defaults synchronize];
}

-(void) logout{
    NSLog(@"Logging Out");
    self.session = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //[defaults removeObjectForKey:USER_DEFAULTS_USERNAME_KEY];
    [defaults removeObjectForKey:USER_DEFAULTS_PASSWORD_KEY];
    [defaults setBool:NO forKey:USER_DEFAULTS_SESSIONSENABLED];
    
    [defaults synchronize];
    NSHTTPCookie *cookie = [self getRestwiseCookie];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookieStorage deleteCookie:cookie];
    
//    MyTabBarController *tabBarController = ((RestwiseAppDelegate *)[[UIApplication sharedApplication] delegate]).tabController;
//    [[[[[tabBarController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0] setEntry:nil];
//    [[[[[tabBarController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0] requiresRefreshToDate:nil];
}

-(void) forgotPasswordForUsername:(NSString *)username delegate:(id) delegate{
    if (emailLoginConnection != nil) {
        return;
    }
    NSLog(@"Emailing password");
    emailLoginDelegate = delegate;
    emailLoginData = nil;
    
    static NSString *loginBodyFormatString = @"username=%@&emailpw=emailpw";
    NSString *bodyString = [NSString stringWithFormat:loginBodyFormatString,username];
    
    NSURL *loginURL = [self getURL:@"login.pfm"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:loginURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSISOLatin1StringEncoding]];
    
    emailLoginConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(BOOL) checkCookieExistance{
    NSHTTPCookie *cookie = [self getRestwiseCookie];
    if (cookie != nil) {
        NSLog(@"Cookie Exists!");
        return YES;
    }
    return NO;
}

-(NSHTTPCookie *) getRestwiseCookie{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookiesForURL:[self getBaseURL]];
    for (NSHTTPCookie *cookie in cookies){
        NSString *cookieName = [cookie name];
        if ([cookieName isEqualToString:@"rmstaging"] ||
            [cookieName isEqualToString:@"recomem"]) {
            return cookie;
        }
    }
    return nil;
}
-(void) loadEntry:(Entry *)entry delegate:(id)delegate{
    if (entryConnection != nil) {
        return;
    }
    if ([self ensureLogin:delegate]) {
        if (entry == nil ||
            [RestwiseManager compareDate:entry.date withDate:[NSDate date]]==NSOrderedDescending) {
            entry = [[Entry alloc] init];
        }
        Entry *savedEntry = [self getOfflineEntryForDate:entry.date forSession:self.session];
        if (![RestwiseManager hasInternetConnection]) {
            
            if (savedEntry != nil) {
                NSLog(@"No connection, loading saved entry");
            }
            else {
                NSLog(@"No connection, loading default");
                savedEntry = [[Entry alloc]init];
                savedEntry.date = entry.date;
            }
            
            [delegate performSelectorOnMainThread:@selector(didGetEntry:) withObject:savedEntry waitUntilDone:NO];
            return;
        }
        NSLog(@"Loading Entry");
        if (savedEntry != nil) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Loading Saved Entry" message:@"You have a saved entry that hasn't been submitted yet." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            [delegate performSelectorOnMainThread:@selector(didGetEntry:) withObject:savedEntry waitUntilDone:NO];
            return;
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        entryDelegate = delegate;
        entryData = nil;
        
        NSMutableString *bodyString = [[NSMutableString alloc] init];
        if (entry != nil && entry.date !=nil) {
            [bodyString appendFormat:@"%@=%@",DATE,[dateFormatter stringFromDate:entry.date]];
            NSLog(@"Loading entry %@",bodyString);
        }
        NSURL *entryURL = [self getURL:@"profile/entry-json.pfm"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:entryURL];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[bodyString dataUsingEncoding:NSISOLatin1StringEncoding]];

        entryConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (void)enterEntry:(Entry *)entry delegate:(id)delegate {
    if(entry == nil){
        return;
    }
    if ([self ensureLogin:delegate]) {
        if (![RestwiseManager hasInternetConnection]) {
            //save entry
            [self saveOfflineEntry:entry forSession:self.session];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Saving offline submission" message:@"You currently don't have an internet connection to the Restwise servers. This will be submitted the next time you open Restwise with an active connection." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [delegate performSelectorOnMainThread:@selector(didEnterEntry:) withObject:entry waitUntilDone:NO];
            return;
        }
        if (enterEntryConnection != nil) {
            return;
        }
        NSMutableString *bodyString = [[NSMutableString alloc] init];
        
        [bodyString appendFormat:@"%@=%@",DATE,[dateFormatter stringFromDate:entry.date]];
        [bodyString appendFormat:@"&%@=%d",SUBMIT_JSON,1];
        [bodyString appendFormat:@"&%@=%@",PULSE,entry.pulse];
        [bodyString appendFormat:@"&%@=%@",WEIGHT,entry.weight];
        [bodyString appendFormat:@"&%@=%@",SLEEP_HOURS,entry.sleepHours];
        [bodyString appendFormat:@"&%@=%d",SLEEP_QUALITY,entry.sleepQuality+1];
        [bodyString appendFormat:@"&%@=%@",HRV,entry.hrv];
        [bodyString appendFormat:@"&%@=%@",SP02,entry.sp02];
        if (entry.soreness==SornessLevelNo) {
            [bodyString appendFormat:@"&%@=%d",SORENESS,0];
        }
        else if (entry.soreness==SornessLevelYes) {
            [bodyString appendFormat:@"&%@=%d",SORENESS,1];
        }
        if (entry.injury==InjuryLevelNo) {
            [bodyString appendFormat:@"&%@=%d",INJURY,0];
        }
        else if (entry.injury==InjuryLevelYes) {
            [bodyString appendFormat:@"&%@=%d",INJURY,1];
        }
        if (entry.menstrual==MenstrualLevelNo) {
            [bodyString appendFormat:@"&%@=%d",MENSTRUAL,0];
        }
        else if (entry.menstrual==MenstrualLevelYes) {
            [bodyString appendFormat:@"&%@=%d",MENSTRUAL,1];
        }
        [bodyString appendFormat:@"&%@=%d",MOOD,entry.mood+1];
        [bodyString appendFormat:@"&%@=%d",ENERGY,entry.energy+1];
        [bodyString appendFormat:@"&%@=%d",PERFORMANCE,entry.performance+1];
        if (entry.illness==IllnessLevelNo) {
            [bodyString appendFormat:@"&%@=%d",ILLNESS,0];
        }
        else if (entry.illness==IllnessLevelYes) {
            [bodyString appendFormat:@"&%@=%d",ILLNESS,1];
        }
        [bodyString appendFormat:@"&%@=%d",APPETITE,entry.appetite];
        
        
        [bodyString appendFormat:@"&%@=%d",URINE_SHADE,entry.urineShade+1];
        if (entry.comments != nil && [[entry.comments stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]!=0) {
            //[bodyString appendFormat:@"&%@=%@",COMMENTS,(NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)entry.comments, NULL, NULL, kCFStringEncodingUTF8)];
            [bodyString appendFormat:@"&%@=%@",COMMENTS,entry.comments];
        }
        
        NSMutableDictionary *myDictionary = [[NSMutableDictionary alloc] init];
        
        [myDictionary setValue:[dateFormatter stringFromDate:entry.date] forKey:DATE];
        [myDictionary setValue:@1 forKey:SUBMIT_JSON];
        [myDictionary setValue:entry.pulse forKey:PULSE];
        [myDictionary setValue:entry.weight forKey:WEIGHT];
        [myDictionary setValue:entry.sleepHours forKey:SLEEP_HOURS];
        [myDictionary setValue:[NSString stringWithFormat:@"%d", entry.sleepQuality+1] forKey:SLEEP_QUALITY];
        [myDictionary setValue:entry.sp02 forKey:SP02];
        [myDictionary setValue:entry.hrv forKey:HRV];
        if (entry.soreness==SornessLevelNo) {
            [myDictionary setValue:@0 forKey:SORENESS];
        }
        else if (entry.soreness==SornessLevelYes) {
            [myDictionary setValue:@1 forKey:SORENESS];
        }
        if (entry.injury==InjuryLevelNo) {
            [myDictionary setValue:@0 forKey:INJURY];
        }
        else if (entry.injury==InjuryLevelYes) {
            [myDictionary setValue:@1 forKey:INJURY];
        }
        if (entry.menstrual==MenstrualLevelNo) {
            [myDictionary setValue:@0 forKey:MENSTRUAL];
        }
        else if (entry.menstrual==MenstrualLevelYes) {
            [myDictionary setValue:@1 forKey:MENSTRUAL];
        }
        [myDictionary setValue:[NSString stringWithFormat:@"%d", entry.mood+1] forKey:MOOD];
        [myDictionary setValue:[NSString stringWithFormat:@"%d", entry.energy+1] forKey:ENERGY];
        [myDictionary setValue:[NSString stringWithFormat:@"%d", entry.performance+1] forKey:PERFORMANCE];
        
        if (entry.illness==IllnessLevelNo) {
            [myDictionary setValue:@0 forKey:ILLNESS];
        }
        else if (entry.illness==IllnessLevelYes) {
            [myDictionary setValue:@1 forKey:ILLNESS];
        }
        [myDictionary setValue:[NSString stringWithFormat:@"%d", entry.appetite+1] forKey:APPETITE];
        [myDictionary setValue:[NSString stringWithFormat:@"%d", entry.urineShade+1] forKey:URINE_SHADE];
        
        if (entry.comments != nil && [[entry.comments stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]!=0) {
            [myDictionary setValue:entry.comments forKey:COMMENTS];
        }
        
        [myDictionary setValue:entry.sessions forKey:SESSIONS];
        
        NSString *jsonString = [myDictionary JSONRepresentation];
        
        //[self sendEntryString:bodyString delegate:delegate];
        [self sendEntryJSON:jsonString delegate:delegate];
    }
}

- (void)sendEntryJSON:(NSString *)pEntryJSON delegate:(id)pDelegate {
    if ([self ensureLogin:pDelegate]) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        enterEntryData = nil;
        enterEntryDelegate = pDelegate;
        
        NSLog(@"Submitting entry with %@",pEntryJSON);
        
        NSURL *enterEntryURL = [self getURL:@"profile/post-entry-json.pfm"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:enterEntryURL];

        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[pEntryJSON dataUsingEncoding:NSISOLatin1StringEncoding]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        enterEntryConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (void)sendEntryString:(NSString *)pEntryString delegate:(id)pDelegate {
    //TODO remove
    if ([self ensureLogin:pDelegate]) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        enterEntryData = nil;
        enterEntryDelegate = pDelegate;
        
        NSLog(@"Submitting entry with %@",pEntryString);
        
        NSURL *enterEntryURL = [self getURL:@"profile/entry-json.pfm"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:enterEntryURL];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[pEntryString dataUsingEncoding:NSISOLatin1StringEncoding]];
        enterEntryConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (void)loadScores:(EntryRange *)entryRange delegate:(id)delegate {
    if (entryRangeConnection != nil) {
        return;
    }
    if (![RestwiseManager hasInternetConnection]) {
        if (entryRange == nil) {
            entryRange = [[EntryRange alloc]init];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Available" message:@"Results are not available while offline." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [delegate performSelectorOnMainThread:@selector(didGetScores:) withObject:entryRange waitUntilDone:NO];
        return;
    }
    NSLog(@"Loading Scores");
    entryRangeDelegate = delegate;
    if ([self ensureLogin:delegate]) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        entryRangeData = nil;
        
        NSMutableString *bodyString = [[NSMutableString alloc] init];
        [bodyString appendFormat:@"w=%d&h=%d",480,320];
        if (entryRange!=nil && entryRange.fromDate !=nil && entryRange.toDate !=nil) {
            [bodyString appendFormat:@"&%@=%@&%@=%@",FROM_DATE,[dateFormatter stringFromDate:entryRange.fromDate],TO_DATE,[dateFormatter stringFromDate:entryRange.toDate]];
        }
        if (entryRange.chartConfig != nil) {
            [bodyString appendFormat:@"&%@=%d",SHOW_COMPONENTS,entryRange.chartConfig.chartComponents];
            [bodyString appendFormat:@"&%@=%d",SP02,entryRange.chartConfig.sp02];
            [bodyString appendFormat:@"&%@=%d",ILLNESS,entryRange.chartConfig.illness];
            [bodyString appendFormat:@"&%@=%d",APPETITE,entryRange.chartConfig.appetite];
            [bodyString appendFormat:@"&%@=%d",URINE_SHADE,entryRange.chartConfig.urine_shade];
            [bodyString appendFormat:@"&%@=%d",PULSE,entryRange.chartConfig.pulse];
            [bodyString appendFormat:@"&%@=%d",SLEEP, entryRange.chartConfig.sleep];
            [bodyString appendFormat:@"&%@=%d",WEIGHT,entryRange.chartConfig.weight];
            [bodyString appendFormat:@"&%@=%d",SORENESS,entryRange.chartConfig.soreness];
            [bodyString appendFormat:@"&%@=%d",MOOD,entryRange.chartConfig.mood];
            [bodyString appendFormat:@"&%@=%d",ENERGY,entryRange.chartConfig.energy];
            [bodyString appendFormat:@"&%@=%d",PERFORMANCE,entryRange.chartConfig.performance];
            //
            [bodyString appendFormat:@"&%@=%d",HRV,entryRange.chartConfig.hrv];
            [bodyString appendFormat:@"&%@=%d",HRVREF,entryRange.chartConfig.hrvRef];
            //[bodyString appendFormat:@"&%@=%d",LOAD,entryRange.chartConfig.load];
            
            if( entryRange.chartConfig.load )
            {
                [bodyString appendFormat:@"&%@=%d",LOAD,1];
            }
        }
        
        NSLog(@"Getting scores with %@",bodyString);
        
        NSURL *scoresURL = [self getURL:@"profile/scores-json.pfm"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:scoresURL];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[bodyString dataUsingEncoding:NSISOLatin1StringEncoding]];

        entryRangeConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

- (void)loadAthletesForDate:(NSDate *)theDate delegate:(id)delegate {
    if (getAthletesConnection != nil) {
        return;
    }
    if (![RestwiseManager hasInternetConnection]) {
        
        [delegate performSelectorOnMainThread:@selector(didErrorGetAthletesNoInternet:) withObject:nil waitUntilDone:NO];
        return;
    }
    NSLog(@"Loading Athletes");
    
    getAthletesDelegate = delegate;
    if ([self ensureLogin:delegate]) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        getAthletesData = nil;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSURL *athletesURL = [self getURL:@"coach/list-athletes.pfm"];
        
        NSString *bodyString = [NSString stringWithFormat:@"date=%@", [dateFormatter stringFromDate:theDate]];
        
        NSLog(@"%@", bodyString);
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:athletesURL];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[bodyString dataUsingEncoding:NSISOLatin1StringEncoding]];
        getAthletesConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
}

-(void) emailChart:(EntryRange *)entryRange toEmail:(NSString *)email delegate:(id)delegate {
    NSLog(@"Emailing chart");
    
    //entryRangeDelegate = delegate;
    if ([self ensureLogin:delegate]) {
        EmailChartManager *emailManager = [[EmailChartManager alloc]init];
        emailManager.delegate = delegate;
        
        NSMutableString *bodyString = [[NSMutableString alloc] init];
        if (entryRange!=nil && entryRange.fromDate !=nil && entryRange.toDate !=nil) {
            [bodyString appendFormat:@"%@=%@&%@=%@&%@=%@",FROM_DATE,[dateFormatter stringFromDate:entryRange.fromDate],TO_DATE,[dateFormatter stringFromDate:entryRange.toDate],EMAIL,email];
        }
        
        NSLog(@"Emailing chart with %@",bodyString);
        
        NSURL *emailChartURL = [self getURL:@"profile/email_chart.pfm"];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:emailChartURL];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[bodyString dataUsingEncoding:NSISOLatin1StringEncoding]];

//        NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:request delegate:emailManager];
    }
}

- (NSURL *)getBaseURL {
    if (baseURL == nil) {
        baseURL = [[NSURL alloc] initWithString:@"http://recovery.restwise.com"];
    }
    return baseURL;
}

- (NSURL *)getURL:(NSString *)url {
    //return [NSURL URLWithString: [NSString stringWithFormat:@"http://recovery.restwise.com/staging/%@",url]];
    return [NSURL URLWithString: [NSString stringWithFormat:@"http://recovery.restwise.com/%@",url]];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSLog(@"Received response %ld",(long)[(NSHTTPURLResponse *)response statusCode]);
    
    if ([(NSHTTPURLResponse *)response statusCode] / 100 != 2 && [(NSHTTPURLResponse *)response statusCode] != 302) {
        //Error
        if (connection == loginConnection) {
            [loginDelegate performSelectorOnMainThread:@selector(loginFailed) withObject:nil waitUntilDone:NO];
            
            loginConnection = nil;
            loginDelegate = nil;
        }
        else if (connection == entryConnection) {
            NSString *errorString = @"Error getting entry data";
            NSError *error = [NSError errorWithDomain:@"RestwiseEntryError" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString,ERROR,nil]];
            [entryDelegate performSelectorOnMainThread:@selector(didErrorGettingEntry:) withObject:error waitUntilDone:NO];
            

            entryConnection = nil;
            entryDelegate = nil;
        }
        else if (connection == emailLoginConnection) {
            NSString *errorString = @"Error emailing password";
            NSError *error = [NSError errorWithDomain:@"RestwiseError" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString,ERROR,nil]];
            [emailLoginDelegate performSelectorOnMainThread:@selector(didErrorEmailingLogin:) withObject:error waitUntilDone:NO];
            
            emailLoginConnection = nil;
            emailLoginDelegate = nil;
            
        }
        else if (connection == entryRangeConnection) {
            NSString *errorString = @"Error getting scores";
            NSError *error = [NSError errorWithDomain:@"RestwiseEntryError" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString,ERROR,nil]];
            [entryRangeDelegate performSelectorOnMainThread:@selector(didErrorGettingScores:) withObject:error waitUntilDone:NO];
            
            entryRangeConnection = nil;
            entryRangeDelegate = nil;
            
        }
        else if (connection == enterEntryConnection) {
            NSString *errorString = @"Error submitting data";
            NSError *error = [NSError errorWithDomain:@"RestwiseEntryError" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString,ERROR,nil]];
            [enterEntryDelegate performSelectorOnMainThread:@selector(didErrorEnteringEntry:) withObject:error waitUntilDone:NO];
            
            enterEntryConnection = nil;
            enterEntryDelegate = nil;
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [connection cancel];
    }
    else if (connection == loginConnection) {
        if ([(NSHTTPURLResponse *)response statusCode] == 302 ||
            [(NSHTTPURLResponse *)response statusCode] == 200) {
            NSLog(@"Login received %ld",(long)[(NSHTTPURLResponse *)response statusCode]);
            BOOL login = [self checkCookieExistance];
            if (login) {
                loginData = [[NSMutableData alloc] init];
                //[loginDelegate performSelectorOnMainThread:@selector(loginSuccessful) withObject:nil waitUntilDone:NO];
            }
            else {
                [loginDelegate performSelectorOnMainThread:@selector(loginFailed) withObject:nil waitUntilDone:NO];
                [connection cancel];

                loginConnection = nil;
                loginDelegate = nil;
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            }
            
        }
        else {
            [loginDelegate performSelectorOnMainThread:@selector(loginFailed) withObject:nil waitUntilDone:NO];
            [connection cancel];

            loginConnection = nil;
            loginDelegate = nil;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }
    else if (connection == emailLoginConnection) {
        emailLoginData = [[NSMutableData alloc] init];
    }
    else if (connection == entryRangeConnection) {
        entryRangeData = [[NSMutableData alloc] init];
    }
    else if (connection == entryConnection) {
        entryData = [[NSMutableData alloc] init];
    }
    else if (connection == enterEntryConnection) {
        enterEntryData = [[NSMutableData alloc] init];
    }
    else if (connection == getAthletesConnection) {
        getAthletesData = [[NSMutableData alloc] init];
    }
    else {
        NSLog(@"Received unknown response");
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSLog(@"Received data");
    if (connection == entryRangeConnection) {
        [entryRangeData appendData:data];
    }
    else if (connection == emailLoginConnection) {
        [emailLoginData appendData:data];
    }
    else if (connection == entryConnection) {
        [entryData appendData:data];
    }
    else if (connection == enterEntryConnection) {
        [enterEntryData appendData:data];
    }
    else if (connection == getAthletesConnection) {
        [getAthletesData appendData:data];
    }
    else if (connection == loginConnection) {
        [loginData appendData:data];
    }
    else {
        NSLog(@"Received data from unknown connection");
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Received error %@",error);
    
    if (connection == entryRangeConnection) {
        [entryRangeDelegate performSelectorOnMainThread:@selector(didErrorGettingScores:) withObject:error waitUntilDone:NO];
        entryRangeDelegate = nil;
        
        entryRangeConnection = nil;
        
        entryRangeData = nil;
    }
    else if (connection == emailLoginConnection) {
        [emailLoginDelegate performSelectorOnMainThread:@selector(didErrorEmailingLogin:) withObject:error waitUntilDone:NO];
        emailLoginDelegate = nil;
        emailLoginConnection = nil;
        emailLoginData = nil;
    }
    else if (connection == getAthletesConnection) {
        [entryDelegate performSelectorOnMainThread:@selector(didErrorGetAthletes:) withObject:error waitUntilDone:NO];
        
        getAthletesConnection = nil;
        getAthletesData = nil;
    }
    else if (connection == entryConnection) {
        [entryDelegate performSelectorOnMainThread:@selector(didErrorGettingEntry:) withObject:error waitUntilDone:NO];
        entryDelegate = nil;
        entryConnection = nil;
        entryData = nil;
    }
    else if (connection == enterEntryConnection) {
        [enterEntryDelegate performSelectorOnMainThread:@selector(didErrorEnteringEntry:) withObject:error waitUntilDone:NO];
        enterEntryDelegate = nil;
        enterEntryConnection = nil;
        enterEntryData = nil;
    }
    else if(connection == loginConnection){
        [loginDelegate performSelectorOnMainThread:@selector(loginFailed) withObject:nil waitUntilDone:NO];
        loginConnection = nil;
        loginDelegate = nil;
        loginData = nil;
    }
    else {
        NSLog(@"Unknown connection failed");
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"Connection finished");
    if (connection == entryRangeConnection) {
        NSString *jsonString = [[NSString alloc] initWithData:entryRangeData encoding:NSUTF8StringEncoding];
        EntryRange *returnedEntryRange = [RestwiseJSON entryRangeFromJSONString:jsonString];
        //TODO check error
        [entryRangeDelegate performSelectorOnMainThread:@selector(didGetScores:) withObject:returnedEntryRange waitUntilDone:NO];
        
        entryRangeConnection = nil;
        entryRangeDelegate = nil;
        entryRangeData = nil;
    }
    else if (connection == entryConnection) {
        NSString *jsonString = [[NSString alloc] initWithData:entryData encoding:NSUTF8StringEncoding];
        Entry *entry = [RestwiseJSON entryFromJSONString:jsonString lastBlock:NO];
        //TODO check error
        [entryDelegate performSelectorOnMainThread:@selector(didGetEntry:) withObject:entry waitUntilDone:NO];
        
        entryConnection = nil;
        entryDelegate = nil;
        entryData = nil;
    }
    else if (connection == getAthletesConnection) {
        NSString *jsonString = [[NSString alloc] initWithData:getAthletesData encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", jsonString);
        
        NSRange noAccessRange = [jsonString rangeOfString:@"Your account is not set up with access to this section"];
        
        if( (noAccessRange.location != NSNotFound) )
        {
            [getAthletesDelegate performSelectorOnMainThread:@selector(didGetAthletesNoAccess:) withObject:nil waitUntilDone:NO];
        }
        else
        {
            NSDictionary *jsonEntry = [jsonString JSONValue];
            [getAthletesDelegate performSelectorOnMainThread:@selector(didGetAthletes:) withObject:jsonEntry waitUntilDone:NO];
        }
        
        getAthletesConnection = nil;
        getAthletesDelegate = nil;
        getAthletesData = nil;
    }
    else if (connection == emailLoginConnection) {
//        NSString *jsonString = [[NSString alloc] initWithData:emailLoginData encoding:NSUTF8StringEncoding];
        //TODO check error
        [emailLoginDelegate performSelectorOnMainThread:@selector(didEmailLogin) withObject:nil waitUntilDone:NO];
        
        emailLoginConnection = nil;
        emailLoginDelegate = nil;
        emailLoginData = nil;
    }
    else if (connection == loginConnection) {
        NSString *jsonString = [[NSString alloc] initWithData:loginData encoding:NSUTF8StringEncoding];
        
        NSDictionary *jsonDict = [jsonString JSONValue];
        
        NSLog(@"%@", jsonString);
        
        NSString  *sex    = [jsonDict objectForKey:@"sex"];
        NSInteger rights  = [[jsonDict objectForKey:@"rights"] intValue];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:NO forKey:USER_DEFAULTS_SESSIONSENABLED];
        [defaults setInteger:rights forKey:USER_DEFAULTS_RIGHTS_KEY];
        [defaults setObject:sex forKey:USER_DEFAULTS_SEX_KEY];
        [defaults synchronize];
        
        [loginDelegate performSelectorOnMainThread:@selector(loginSuccessful) withObject:nil waitUntilDone:NO];
        
        loginConnection = nil;
        loginDelegate = nil;
        loginData = nil;
    }
    else if (connection == enterEntryConnection) {
        NSString *jsonString = [[NSString alloc] initWithData:enterEntryData encoding:NSUTF8StringEncoding];
        Entry *entry = [RestwiseJSON entryFromJSONString:jsonString lastBlock:NO];
        if (entry.error != nil) {
            NSLog(@"Error submitting: %@",entry.error);
            NSError *error = [NSError errorWithDomain:RESTWISE_ERROR_VALIDATION code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:entry.error,ERROR,entry.date,RESTWISE_ERROR_VALIDATION_DATE,nil]];
            [enterEntryDelegate performSelectorOnMainThread:@selector(didErrorEnteringEntry:) withObject:error waitUntilDone:NO];
        }
        else{
            //Check status message
            //if (entry.status != nil && [entry.status isEqualToString:STATUS_SUCCESS]) {
            //Success
            [self removeOfflineEntry:entry.date forUser:self.session.username];
            [enterEntryDelegate performSelectorOnMainThread:@selector(didEnterEntry:) withObject:entry waitUntilDone:NO];
            //}
            //    else {
            //      NSString *errorString = entry.error;
            //      if (errorString==nil) {
            //        errorString = @"Error submitting data";
            //      }
            //      NSError *error = [NSError errorWithDomain:@"RestwiseEntryError" code:-1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorString,ERROR,nil]];
            //      [enterEntryDelegate performSelectorOnMainThread:@selector(didErrorEnteringEntry:) withObject:error waitUntilDone:NO];
        }
        
        enterEntryConnection = nil;
        enterEntryDelegate = nil;
        enterEntryData = nil;
    }
    else {
        NSLog(@"Finished unknown connection");
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

+(BOOL)hasInternetConnection{
    //return NO;
    Reachability *reachability = [Reachability reachabilityWithHostName:@"http://recovery.restwise.com"];
    NetworkStatus status = [reachability currentReachabilityStatus];
    return (status == ReachableViaWiFi) || (status == ReachableViaWWAN);
}
-(NSMutableDictionary *)getOfflineEntries{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *entries = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:USER_DEFAULTS_OFFLINE_ENTRY_KEY]];
    if (entries == nil) {
        entries = [NSMutableDictionary dictionary];
    }
    return entries;
}
-(NSMutableDictionary *) getUserOfflineEntries:(NSString *)username fromEntries:(NSMutableDictionary *)offlineEntries{
    NSMutableDictionary *userEntries = [NSMutableDictionary dictionaryWithDictionary:[offlineEntries objectForKey:username]];
    if(userEntries == nil){
        userEntries = [NSMutableDictionary dictionary];
    }
    return userEntries;
}
-(void) saveUserOfflineEntries:(NSMutableDictionary *) userEntries forUsername:(NSString *)username toEntries:(NSMutableDictionary *)offlineEntries{
    [offlineEntries setObject:userEntries forKey:username];
}
-(NSMutableDictionary *) packageEntry:(NSString *)jsonEntry forSession:(RestwiseSession *)pSession{
    NSMutableDictionary *entryDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:pSession.username,USER_DEFAULTS_USERNAME_KEY,
                                      pSession.password, USER_DEFAULTS_PASSWORD_KEY,jsonEntry, USER_DEFAULTS_OFFLINE_ENTRY_KEY, nil];
    return entryDict;
}

-(void) saveOfflineEntry:(Entry *)entry forSession:(RestwiseSession *)pSession{
    NSString *jsonEntry = [RestwiseJSON JSONStringFromEntry:entry];
    NSLog(@"Saving entry for offline submition: %@",jsonEntry);
    
    NSMutableDictionary *offlineEntries = [self getOfflineEntries];
    NSMutableDictionary *userEntries = [self getUserOfflineEntries:pSession.username fromEntries:offlineEntries];
    [userEntries setObject:[self packageEntry:jsonEntry forSession:pSession] forKey:[dateFormatter stringFromDate:entry.date]];
    [self saveUserOfflineEntries:userEntries forUsername:pSession.username toEntries:offlineEntries];
    [self saveOfflineEntires:offlineEntries];
}
-(void)saveOfflineEntires:(NSDictionary *)entries{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:entries forKey:USER_DEFAULTS_OFFLINE_ENTRY_KEY];
    [defaults synchronize];
}
-(int)hasOfflineEntires{
    if (![RestwiseManager hasInternetConnection]) {
        NSLog(@"Still offline, not loading offline entries");
        return 0;
    }
    int count = 0;
    NSMutableDictionary *entries = [self getOfflineEntries];
    if(entries != nil){
        for(NSDictionary *userEntires in [entries allValues]){
            count += [userEntires count];
        }
    }
    NSLog(@"Found %lu saved users with %d entries.",(unsigned long)[entries count],count);
    return count;
}
-(Entry *)getOfflineEntryForDate:(NSDate *)date forSession:(RestwiseSession *)pSession{
    NSMutableDictionary *entries = [self getOfflineEntries];
    NSMutableDictionary *userEntries = [self getUserOfflineEntries:pSession.username fromEntries:entries];
    
    NSString *dateString = [dateFormatter stringFromDate:date];
    NSMutableDictionary *dateEntryDict = [userEntries objectForKey:dateString];
    NSString *entryStr = [dateEntryDict objectForKey:USER_DEFAULTS_OFFLINE_ENTRY_KEY];
    if(entryStr != nil){
        Entry *entry = [RestwiseJSON entryFromJSONString:entryStr lastBlock:NO];
        return entry;
    }
    
    return nil;
}
-(BOOL)loadOfflineEntriesForUser:(NSString *)username fromEntries:(NSMutableDictionary *)entries delegate:(id)pDelegate{
    NSDictionary *userEntries = [entries objectForKey:username];
    NSDictionary *dateEntry = [[userEntries allValues] objectAtIndex:0];
    //NSString *usernameValue = [dateEntry objectForKey:USER_DEFAULTS_USERNAME_KEY];
    NSString *passwordValue = [dateEntry objectForKey:USER_DEFAULTS_PASSWORD_KEY];
    Entry *entry = [RestwiseJSON entryFromJSONString:[dateEntry objectForKey:USER_DEFAULTS_OFFLINE_ENTRY_KEY] lastBlock:NO];
    if(dateEntry == nil || entry == nil){
        if(self.previousSession != nil){
            //Replace username of previous session with current session
            userEntries = [entries objectForKey:self.previousSession.username];
            if (userEntries == nil || [userEntries count] == 0) {
                return NO;
            }
            [entries setObject:userEntries forKey:username];
            [entries removeObjectForKey:self.previousSession.username];
            
            //Save entries
            [self saveOfflineEntires:entries];
            
            return [self loadOfflineEntriesForUser:username fromEntries:entries delegate:pDelegate];
        }
        else{
            return NO;
        }
    }
    else{
        if ([self checkCookieExistance] && self.session.username == username) {
            [self enterEntry:entry delegate:pDelegate];
            return YES;
        }
        else{
            [self logout];
            [self logInWithUsername:username password:passwordValue delegate:pDelegate];
            return YES;
        }
    }
}
-(void)loadOfflineEntries:(id)pDelegate{
    NSMutableDictionary *entries = [self getOfflineEntries];
    if(entries != nil){
        NSLog(@"Found %lu saved users.",(unsigned long)[entries count]);
        if([entries count]>0) {
            if ([RestwiseManager hasInternetConnection]) {
                self.loadingOfflineEntires = YES;
                // load current user's
                NSString *currentUsername = [self getCurrentUsername];
                if(![self loadOfflineEntriesForUser:currentUsername fromEntries:entries delegate:pDelegate]){
                    //logout
                    [self logout];
                    //load other user   
                    [self loadOfflineEntriesForUser:[[entries allKeys] objectAtIndex:0] fromEntries:entries delegate:pDelegate];
                }
            }
        }
    }
    else {
        NSLog(@"No saved entires");
    }
    
}
-(void)removeOfflineEntry:(NSDate *)entryDate forUser:(NSString *)username{  
    NSMutableDictionary *entries = [self getOfflineEntries];
    NSMutableDictionary *userEntries = [self getUserOfflineEntries:username fromEntries:entries];
    NSString *dateString = [dateFormatter stringFromDate:entryDate];
    NSLog(@"Removing offline entry for %@ on %@.",username, dateString);
    [userEntries removeObjectForKey:dateString];
    if ([userEntries count]==0) {
        [entries removeObjectForKey:username];
    }
    else{
        [entries setObject:userEntries forKey:username];
    }
    if ([entries count]==0) {
        if (self.loadingOfflineEntires) {
            [self logout];
        }
    }
    [self saveOfflineEntires:entries];
}

@end

@implementation EmailChartManager

@synthesize delegate;

- (NSURLRequest *)connection:(NSURLConnection *)pConnection  willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse{  
    if (redirectResponse != nil) {    
        NSLog(@"Email chart received redirect response with status of %ld",(long)[(NSHTTPURLResponse *)redirectResponse statusCode]);    
        return nil;
    }
    else {
        return request;
    }
}

- (void)connection:(NSURLConnection *)pConnection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"Email chart received response with status of %ld",(long)[(NSHTTPURLResponse *)response statusCode]);
    [connection cancel];
    connection = nil;
    
    if ([(NSHTTPURLResponse *)response statusCode] == 302) {
        [delegate performSelectorOnMainThread:@selector(didEmailChart) withObject:nil waitUntilDone:NO];
    }
    else {
        [delegate performSelectorOnMainThread:@selector(didErrorEmailingChart:) withObject:nil waitUntilDone:NO];
    }
    delegate = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [delegate performSelectorOnMainThread:@selector(didErrorEmailingChart:) withObject:error waitUntilDone:NO];
    delegate = nil;
}

@end
