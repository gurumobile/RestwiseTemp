//
//  NSString+SBJSON.h
//  Restwise
//
//  Created by Bogdan on 11/12/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SBJSON)

/**
 @brief Returns the object represented in the receiver, or nil on error.
 
 Returns a a scalar object represented by the string's JSON fragment representation.
 */
- (id)JSONFragmentValue;

/**
 @brief Returns the NSDictionary or NSArray represented by the current string's JSON representation.
 
 Returns the dictionary or array represented in the receiver, or nil on error.
 
 Returns the NSDictionary or NSArray represented by the current string's JSON representation.
 */
- (id)JSONValue;

@end
