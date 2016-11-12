//
//  ChartConfiguration.h
//  Restwise
//
//  Created by Bogdan on 11/10/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChartConfiguration : NSObject <NSCopying>

@property (nonatomic, assign) BOOL sp02;
@property (nonatomic, assign) BOOL illness;
@property (nonatomic, assign) BOOL appetite;
@property (nonatomic, assign) BOOL urine_shade;
@property (nonatomic, assign) BOOL pulse;
@property (nonatomic, assign) BOOL sleep;
@property (nonatomic, assign) BOOL weight;
@property (nonatomic, assign) BOOL soreness;
@property (nonatomic, assign) BOOL mood;
@property (nonatomic, assign) BOOL energy;
@property (nonatomic, assign) BOOL performance;
@property (nonatomic, assign) BOOL load;
@property (nonatomic, assign) BOOL hrv;
@property (nonatomic, assign) BOOL hrvRef;
@property (nonatomic, assign) BOOL chartComponents;

@end
