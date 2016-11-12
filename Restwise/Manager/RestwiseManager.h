//
//  RestwiseManager.h
//  Restwise
//
//  Created by Bogdan on 11/12/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entry.h"
#import "EntryRange.h"
#import "RestwiseSession.h"

extern NSString *const USER_DEFAULTS_USERNAME_KEY;
extern NSString *const USER_DEFAULTS_PASSWORD_KEY;
extern NSString *const USER_DEFAULTS_OFFLINE_ENTRY_KEY;
extern NSString *const RESTWISE_ERROR_VALIDATION;
extern NSString *const RESTWISE_ERROR_VALIDATION_DATE;
extern NSString *const USER_DEFAULTS_SESSION_ACTIVITIES;
extern NSString *const USER_DEFAULTS_SESSIONSENABLED;

@protocol RestwiseManagerDelegate;
@protocol RestwiseManagerScoresDelegate;
@protocol RestwiseManagerEntryDelegate;
@protocol RestwiseManagerLoginDelegate;
@protocol RestwiseManagerEnterEntryDelegate;
@protocol RestwiseManagerEmailChartDelegate;
@protocol RestwiseManagerEmailLoginDelegate;
@protocol RestwiseManagerAthletesDelegate;

@interface EmailChartManager : NSObject
{
    NSURLConnection *connection;
//    id delegate;
}
//@property (nonatomic, weak) id <ColorLineDelegate> delegate;
@property (nonatomic, weak) id delegate;

@end

@interface RestwiseManager : NSObject {
    NSURL *baseURL;
    NSURLConnection *loginConnection;
    NSURLConnection *emailLoginConnection;
    NSURLConnection *entryConnection;
    NSURLConnection *entryRangeConnection;
    NSURLConnection *enterEntryConnection;
    NSURLConnection *getAthletesConnection;
    id loginDelegate;
    id emailLoginDelegate;
    id entryRangeDelegate;
    id entryDelegate;
    id enterEntryDelegate;
    id getAthletesDelegate;
    NSMutableData *emailLoginData;
    NSMutableData *loginData;
    NSMutableData *entryRangeData;
    NSMutableData *entryData;
    NSMutableData *enterEntryData;
    NSMutableData *getAthletesData;
    NSDateFormatter *dateFormatter;
    BOOL loadingOfflineEntires;
    
    RestwiseSession *session;
    RestwiseSession *previousSession;
}

@property (retain) RestwiseSession *session;
@property (retain) RestwiseSession *previousSession;
@property BOOL loadingOfflineEntires;
/*
 Get singleton RestwiseManager
 */
+(RestwiseManager *)sharedRestwiseManager;

/*
 Determines if 2 dates are on the same day.
 */
+ (BOOL)isSameDay:(NSDate*)date1 and:(NSDate*)date2;
/*
 Compares 2 dates
 */
+(NSComparisonResult)compareDate:(NSDate *)date1 withDate:(NSDate *)date2;
/*
 Determines if an entries last entered data is yesturday
 */
+ (BOOL)isPreviousDayTheLastEntered:(Entry*)entry;

/*
 Returns if current signed in account is that of a male.
 */
+ (BOOL)isUserMale;

/*
 Returns the rights of the current signed in account.
 */
+ (NSInteger)getUserRights;

/*
 Check if the user is logged in based on the existance of a cookie.
 */
-(BOOL) checkCookieExistance;

/*
 Gets the Restwise Cookie
 */
-(NSHTTPCookie *) getRestwiseCookie;

/*
 Checks if the user is logged in and notifies the RestwiseManagerDelegate if the user is not logged in.
 */
-(BOOL) ensureLogin:(id) delegate;

/*
 Loads an entry. If an etry is passed in, the date of the entry is used. If entry is null the current date will be loaded. The RestwiseManagerEntryDelegate specified will be notified with the Entry or error.
 */
-(void) loadEntry:(Entry *)entry delegate:(id)delegate;

/*
 Submits an entry. The RestwiseManagerEnterEntryDelegate specified will be notifice with the submitted Entry or error.
 */
-(void) enterEntry:(Entry *)entry delegate:(id)delegate;

/*
 Submits an entry string. The RestwiseManagerEnterEntryDelegate specified will be notifice with the submitted Entry or error.
 */
-(void)sendEntryString:(NSString *)pEntryString delegate:(id)pDelegate;
-(void)sendEntryJSON:(NSString *)pEntryJSON delegate:(id)pDelegate;

/*
 Loads the scores. If an EntryRange is specified, it's date range will be used. Otherwise the default date range will be returned. The RestwiseManagerScoresDelegate specified will be notified with the EntryRange or error.
 */
-(void) loadScores:(EntryRange *)entryRange delegate:(id)delegate;

/*
 */
-(void) loadAthletesForDate:(NSDate *)theDate delegate:(id)delegate;

/*
 Emails the chart
 */
-(void) emailChart:(EntryRange *)entryRange toEmail:(NSString *)email delegate:(id)delegate;

/*
 Gets the base url for the Restwise server.
 */
-(NSURL *) getBaseURL;

/*
 Gets a url relative to the Base Restwise URL.
 */
-(NSURL *) getURL:(NSString *)url;

/*
 Logs in with the supplied username and password. The RestwiseManagerLoginDelegate will be notified if login was suffessful or not.
 */
- (void) logInWithUsername:(NSString *)username password:(NSString *)password delegate:(id) delegate;

/*
 Logs out
 */
-(void) logout;

/*
 Sends the user their password info if they forgot it.
 */
-(void) forgotPasswordForUsername:(NSString *)username delegate:(id) delegate;

/*
 Checks if there is an internet connection to the Restwise server
 */
+(BOOL)hasInternetConnection;
/*
 Gets all offline entries. The key is a date string and the value is a JSON
 representation of an entry.
 */
-(NSMutableDictionary *)getOfflineEntries;
/*
 Save an entry for a user
 */
-(void) saveOfflineEntry:(Entry *)entry forSession:(RestwiseSession *)pSession;
/*
 Persists the offline entries
 */
-(void)saveOfflineEntires:(NSDictionary *)entries;
/*
 Checks if there are any saved entries.
 */
-(int)hasOfflineEntires;
/*
 Checks if there is a saved entry for a particular date
 */
-(Entry *)getOfflineEntryForDate:(NSDate *)date forSession:(RestwiseSession *)pSession;
/*
 Loads any offline entries
 */
-(void)loadOfflineEntries:(id)delegate;

/*
 Removes a saved offline entry
 */
-(void)removeOfflineEntry:(NSDate *)entryDate forUser:(NSString *)username;

@end

/*
 All views using the RestwiseManager should implment this. They will be notified if the user is not logged in and is trying to access restricted content.
 */
@protocol RestwiseManagerDelegate <NSObject>

/*
 Called when the user is not logged in and should present the user with a way to log in.
 */
-(void)requiresLogin;

/*
 Called when the user is being logged in with stored credentials
 */
-(void) loggingIn;


@end

/*
 Delegate of the log in.
 */
@protocol RestwiseManagerLoginDelegate <NSObject>
/*
 Notified when the login was successful
 */
-(void)loginSuccessful;

/*
 Notified when the login failed.
 */
-(void)loginFailed;

@end

/*
 Delegate for getting scores
 */
@protocol RestwiseManagerScoresDelegate <NSObject>

/*
 Called when the scores are received.
 */
-(void)didGetScores:(EntryRange *)entryRange;

/*
 Called if getting the scores failed.
 */
-(void)didErrorGettingScores:(NSError *)error;

@end

/*
 Delgate for getting an entry
 */
@protocol RestwiseManagerEntryDelegate <NSObject>
/*
 Called when the entry is received
 */
-(void) didGetEntry:(Entry *)entry;

/*
 Called if getting the entry failed.
 */
-(void) didErrorGettingEntry:(NSError *)error;

@end

/*
 Delegate for submiting an entry
 */
@protocol RestwiseManagerEnterEntryDelegate <NSObject>

/*
 Called when the entry was successfully submitted.
 */
-(void) didEnterEntry:(Entry *)entry;

/*
 Called if submitting the entry failed.
 */
-(void) didErrorEnteringEntry:(NSError *)error;

@end

/*
 Delegate for emailing chart
 */
@protocol RestwiseManagerEmailChartDelegate
/*
 Called when the chart is emailed
 */
-(void) didEmailChart;
/*
 Called if emailing the chart failed
 */
-(void) didErrorEmailingChart:(NSError *)error;
@end
/*
 Delegate for emailing password
 */
@protocol RestwiseManagerEmailLoginDelegate

/*
 Called when the password email is sent
 */
-(void) didEmailLogin;

/*
 Called if emailing the password failed
 */
-(void) didErrorEmailingLogin:(NSError *)error;

@end
/*
 Delegate for emailing password
 */
@protocol RestwiseManagerAthletesDelegate

/*
 Called when the get athletes is sent
 */
-(void) didGetAthletes:(NSDictionary *)athletes;

/*
 Called when the get athletes is sent and no access is allowed
 */
-(void) didErrorGetAthletesNoInternet:(id)ignored;

/*
 Called when the get athletes is sent and no access is allowed
 */
-(void) didGetAthletesNoAccess:(id)ignored;

/*
 Called if get athletes failed
 */
-(void) didErrorGetAthletes:(NSError *)error;

@end
