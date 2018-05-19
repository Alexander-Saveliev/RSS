//
//  _
//  _
//
//  Created by _ on 11/11/13.
//  Copyright (c) _, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSDate+RFC.h"

@interface NSDate ()

+ (NSDate *)dateWithRFC3339String:(NSString *)dateString;

+ (NSDate *)dateWithRFC822String:(NSString *)dateString;

@end;

@implementation NSDate (RFC)

// Get a date from a RFC standard string
+ (NSDate *)dateWithRFCString:(NSString *)dateString format:(ISDateFormat)format
{
    if ((dateString == nil) || ([dateString isEqualToString:@""])) {
        return nil;
    }
    
	NSDate *date = nil;
	if (format != ISDateFormatRFC3339) {
		// Try RFC822 first
		date = [NSDate dateFromRFC822String:dateString];
		if (!date) date = [NSDate dateFromRFC3339String:dateString];
	} else {
		// Try RFC3339 first
		date = [NSDate dateFromRFC3339String:dateString];
		if (!date) date = [NSDate dateFromRFC822String:dateString];
	}
	return date;
}

+ (NSDate *)dateFromRFC822String:(NSString *)dateString
{
	// Create date formatter
	static NSDateFormatter *dateFormatter = nil;
	if (!dateFormatter) {
		NSLocale *en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setLocale:en_US_POSIX];
		[dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	}
    
	// Process
	NSDate *date = nil;
	NSString *RFC822String = [[NSString stringWithString:dateString] uppercaseString];
	if ([RFC822String rangeOfString:@","].location != NSNotFound) {
		if (!date) { // Sun, 19 May 2002 15:21:36 GMT
			[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss zzz"];
			date = [dateFormatter dateFromString:RFC822String];
		}
		if (!date) { // Sun, 19 May 2002 15:21 GMT
			[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm zzz"];
			date = [dateFormatter dateFromString:RFC822String];
		}
		if (!date) { // Sun, 19 May 2002 15:21:36
			[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss"];
			date = [dateFormatter dateFromString:RFC822String];
		}
		if (!date) { // Sun, 19 May 2002 15:21
			[dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm"];
			date = [dateFormatter dateFromString:RFC822String];
		}
	} else {
		if (!date) { // 19 May 2002 15:21:36 GMT
			[dateFormatter setDateFormat:@"d MMM yyyy HH:mm:ss zzz"];
			date = [dateFormatter dateFromString:RFC822String];
		}
		if (!date) { // 19 May 2002 15:21 GMT
			[dateFormatter setDateFormat:@"d MMM yyyy HH:mm zzz"];
			date = [dateFormatter dateFromString:RFC822String];
		}
		if (!date) { // 19 May 2002 15:21:36
			[dateFormatter setDateFormat:@"d MMM yyyy HH:mm:ss"];
			date = [dateFormatter dateFromString:RFC822String];
		}
		if (!date) { // 19 May 2002 15:21
			[dateFormatter setDateFormat:@"d MMM yyyy HH:mm"];
			date = [dateFormatter dateFromString:RFC822String];
		}
	}
	if (!date) {
        NSLog(@"Could not parse RFC822 date: \"%@\" Possibly invalid format.", dateString);
    }
    return date;
}

+ (NSDate *)dateFromRFC3339String:(NSString *)dateString {
	
	// Create date formatter

    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
	// Process date
	NSDate *date = nil;
	NSString *RFC3339String = [[NSString stringWithString:dateString] uppercaseString];
	RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@"Z" withString:@"-0000"];
	
	if (RFC3339String.length > 20) {
		RFC3339String = [RFC3339String stringByReplacingOccurrencesOfString:@":" withString:@"" options:0
																	  range:NSMakeRange(20, RFC3339String.length-20)];
	}
	if (!date) { // 1996-12-19T16:39:57-0800
        [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
		date = [rfc3339DateFormatter dateFromString:RFC3339String];
	}
	if (!date) { // 1996-12-19T16:39:57-0800
		[rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"];
		date = [rfc3339DateFormatter dateFromString:RFC3339String];
	}
	if (!date) { // 1937-01-01T12:00:27.87+0020
		[rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZZZ"];
		date = [rfc3339DateFormatter dateFromString:RFC3339String];
	}
	if (!date) { // 1937-01-01T12:00:27
		[rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss"];
		date = [rfc3339DateFormatter dateFromString:RFC3339String];
	}
	if (!date) { // 1937-01-01 12:00:27
		[rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss"];
		date = [rfc3339DateFormatter dateFromString:RFC3339String];
	}
	if (!date){
        NSLog(@"Could not parse RFC3339 date: \"%@\" Possibly invalid format.", dateString);
    }
    return date;
	
}

@end

