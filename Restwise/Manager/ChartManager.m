//
//  ChartManager.m
//  Restwise
//
//  Created by Bogdan on 11/12/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "ChartManager.h"

@implementation ChartManager

//@synthesize delegation;

- (void) getChartForEntryRange:(EntryRange *)entryRange{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    //TODO check that only one is running or terminate
    chartData = nil;
    static NSString *urlString = @"http://chart.apis.google.com/chart";
    
    NSString *bodyString = [[entryRange.chartURLString componentsSeparatedByString:@"?"] objectAtIndex:1];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSISOLatin1StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
    if (connection == nil) {
        NSLog(@"Connection is nil");
        //Send error on delegate
    }
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSLog(@"Received response getting chart %ld",(long)[(NSHTTPURLResponse *)response statusCode]);
    //TODO if none 200
    chartData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [chartData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"Received error getting chart %@",error);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    //TODO notify delegate
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSLog(@"Connection finished for chart");
    
    UIImage *image = [[UIImage alloc] initWithData:chartData];
    
    [self.delegate performSelectorOnMainThread:@selector(didGetChartImage:) withObject:image waitUntilDone:YES];

    chartData = nil;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
