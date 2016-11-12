
//
//  NSString+SBJSON.m
//  Restwise
//
//  Created by Bogdan on 11/12/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import "NSString+SBJSON.h"
#import "SBJsonParser.h"

@implementation NSString (SBJSON)

- (id)JSONFragmentValue {
    SBJsonParser *jsonParser = [SBJsonParser new];
    id repr = [jsonParser fragmentWithString:self];
    
    if (!repr)
        NSLog(@"-JSONFragmentValue failed. Error trace is: %@", [jsonParser errorTrace]);
    
    return repr;
}

#if 0
{
    "to_date_score": "",
    "score_explanation": "no data",
    "num_days": "8",
    "cooked_data": [
                    {
                        "date": "04-01-2013",
                        "comments": "dddeee",
                        "score": "30",
                        "sp02": "0",
                        "illness": "6.575",
                        "appetite": "6.575",
                        "urine_shade": "6.575",
                        "pulse": "0",
                        "sleep": "0",
                        "weight": "0",
                        "soreness": "6.575",
                        "mood": "0",
                        "energy": "0",
                        "performance": "0",
                        "load": 0
                    },{
                        "date": "04-02-2013",
                        "comments": "",
                        "score": "",
                        "sp02": "",
                        "illness": "",
                        "appetite": "",
                        "urine_shade": "",
                        "pulse": "",
                        "sleep": "",
                        "weight": "",
                        "soreness": "",
                        "mood": "",
                        "energy": "",
                        "performance": "",
                        "load":
                    },{
                        "date": "04-03-2013",
                        "comments": "goodbee",
                        "score": "20",
                        "sp02": "0",
                        "illness": "7",
                        "appetite": "0",
                        "urine_shade": "7",
                        "pulse": "0",
                        "sleep": "0",
                        "weight": "0",
                        "soreness": "7",
                        "mood": "0",
                        "energy": "0",
                        "performance": "0",
                        "load": 0
                    },{
                        "date": "04-04-2013",
                        "comments": "ddddd",
                        "score": "30",
                        "sp02": "0",
                        "illness": "6.575",
                        "appetite": "6.575",
                        "urine_shade": "6.575",
                        "pulse": "0",
                        "sleep": "0",
                        "weight": "0",
                        "soreness": "6.575",
                        "mood": "0",
                        "energy": "0",
                        "performance": "0",
                        "load": 0
                    },{
                        "date": "04-05-2013",
                        "comments": "",
                        "score": "30",
                        "sp02": "0",
                        "illness": "6.575",
                        "appetite": "6.575",
                        "urine_shade": "6.575",
                        "pulse": "0",
                        "sleep": "0",
                        "weight": "0",
                        "soreness": "6.575",
                        "mood": "0",
                        "energy": "0",
                        "performance": "0",
                        "load": 0
                    },{
                        "date": "04-06-2013",
                        "comments": "",
                        "score": "",
                        "sp02": "",
                        "illness": "",
                        "appetite": "",
                        "urine_shade": "",
                        "pulse": "",
                        "sleep": "",
                        "weight": "",
                        "soreness": "",
                        "mood": "",
                        "energy": "",
                        "performance": "",
                        "load":
                    },{
                        "date": "04-07-2013",
                        "comments": "",
                        "score": "",
                        "sp02": "",
                        "illness": "",
                        "appetite": "",
                        "urine_shade": "",
                        "pulse": "",
                        "sleep": "",
                        "weight": "",
                        "soreness": "",
                        "mood": "",
                        "energy": "",
                        "performance": "",
                        "load":
                    },{
                        "date": "04-08-2013",
                        "comments": "",
                        "score": "",
                        "sp02": "",
                        "illness": "",
                        "appetite": "",
                        "urine_shade": "",
                        "pulse": "",
                        "sleep": "",
                        "weight": "",
                        "soreness": "",
                        "mood": "",
                        "energy": "",
                        "performance": "",
                        "load":
                    }
                    ],
    "chart_url": "http://chart.apis.google.com/chart?chxp=10,19,28,37,46,55,64,73,84,93,102&chxl=0:|04/01|04/02|04/03|04/04|04/05|04/06|04/07|04/08|1:||0|10|20|30|40|50|60|70|80|90|100&chs=480x320&chd=e0:F0__F0F0F0______,Jp__J5JpJp______,Jp__F0JpJp______,Jp__J5JpJp______,F0__F0F0F0______,F0__F0F0F0______,F0__F0F0F0______,Jp__J5JpJp______,F0__F0F0F0______,F0__F0F0F0______,F0__F0F0F0______,F0__F0F0F0______,VH__SCVHVH______&cht=lc&chm=D,336699,12,0,4,0|o,336699,12,-1,9,0|o,FFFFFF,12,-1,7,0&chp=0.1&chxt=x,y&chf=c,ls,90,DABABA,0.136363636363636,E8BABA,0.181818181818182,EDBABA,0.0909090909090909,F6BABA,0.0909090909090909,FFC8BA,0.0909090909090909,FFE3BA,0.0909090909090909,FFF1BA,0.0909090909090909,C8FFC8,0.0909090909090909,BAE8BA,0.0909090909090909,BADABA,0.0454545454545455|bg,s,FFFFFF&chco=C3A5C3,88A588,55A5B5,B5B580,FDE888,E14C4C,FF8F4C,C3FFFF,A5D2FF,5A96B4,5BFF45,ff4444&chbh=r,0.7",
    "chart_width": "480",
    "chart_height": "320"
}
#endif

- (id)JSONValue {
    SBJsonParser *jsonParser = [SBJsonParser new];
    id repr = [jsonParser objectWithString:self];
    
    if (!repr)
        NSLog(@"-JSONValue failed. Error trace is: %@", [jsonParser errorTrace]);

    return repr;
}

@end
