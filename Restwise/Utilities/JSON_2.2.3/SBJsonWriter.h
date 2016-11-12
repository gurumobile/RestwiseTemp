//
//  SBJsonWriter.h
//  Restwise
//
//  Created by Bogdan on 11/12/16.
//  Copyright © 2016 Bogdan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJsonBase.h"

@protocol SBJsonWriterDelegate

/**
 @brief Whether we are generating human-readable (multiline) JSON.
 
 Set whether or not to generate human-readable JSON. The default is NO, which produces
 JSON without any whitespace. (Except inside strings.) If set to YES, generates human-readable
 JSON with linebreaks after each array value and dictionary key/value pair, indented two
 spaces per nesting level.
 */
@property BOOL humanReadable;

/**
 @brief Whether or not to sort the dictionary keys in the output.
 
 If this is set to YES, the dictionary keys in the JSON output will be in sorted order.
 (This is useful if you need to compare two structures, for example.) The default is NO.
 */
@property BOOL sortKeys;

/**
 @brief Return JSON representation (or fragment) for the given object.
 
 Returns a string containing JSON representation of the passed in value, or nil on error.
 If nil is returned and @p error is not NULL, @p *error can be interrogated to find the cause of the error.
 
 @param value any instance that can be represented as a JSON fragment
 
 */
- (NSString*)stringWithObject:(id)value;

@end

@interface SBJsonWriter : SBJsonBase <SBJsonWriterDelegate> {
    @private
    BOOL sortKeys, humanReadable;
}

- (BOOL)appendValue:(id)fragment into:(NSMutableString*)json;
- (BOOL)appendArray:(NSArray*)fragment into:(NSMutableString*)json;
- (BOOL)appendDictionary:(NSDictionary*)fragment into:(NSMutableString*)json;
- (BOOL)appendString:(NSString*)fragment into:(NSMutableString*)json;

- (NSString*)indent;

@end

@interface SBJsonWriter (Private)

- (NSString*)stringWithFragment:(id)value;

@end

@interface NSObject (SBProxyForJson)

- (id)proxyForJson;

@end
