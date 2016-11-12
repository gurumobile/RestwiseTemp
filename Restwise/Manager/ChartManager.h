//
//  ChartManager.h
//  Restwise
//
//  Created by Bogdan on 11/12/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EntryRange.h"

/*
 Delegate for getting chart images
 */
@protocol ChartManagerDelegate

/*
 Called when the image is received
 */
- (void) didGetChartImage:(UIImage *)image;

@end

@interface ChartManager : NSObject {
    NSMutableData *chartData;
//    id delegation;
}

@property (nonatomic, weak) id delegate;

/*
 Gets the chart image for a specified EntryRange. The ChartManagerDelegate is notified when the image is received.
 */
-(void)getChartForEntryRange:(EntryRange *) entryRange;

@end
