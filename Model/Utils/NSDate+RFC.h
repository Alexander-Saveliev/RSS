//
//  _
//  _
//
//  Created by _ on 11/11/13.
//  Copyright (c) 2013 _, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

// Date format hints for parsing date from internet string
typedef NS_ENUM(NSInteger, ISDateFormat)
{
    ISDateFormatNone,
    ISDateFormatRFC822,
    ISDateFormatRFC3339
};

@interface NSDate (RFC)

+ (NSDate *)dateWithRFCString:(NSString *)dateString format:(ISDateFormat)format;

@end
