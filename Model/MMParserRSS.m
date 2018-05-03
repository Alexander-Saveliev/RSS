//
//  MMParserRSS.m
//  RSS
//
//  Created by Marty on 21/04/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMParserRSS.h"
#include "MMElementRSS.h"

@interface MMParserRSS () <NSXMLParserDelegate> {
    BOOL              _inProcess;
    BOOL              _updated;
    NSMutableArray  * _arrXMLData;
    NSMutableString * _strXMLString;
    NSData          * _data;
    
    NSString * _channelTitle;
    NSURL    * _channelLink;
    NSString * _channelDescription;
    
    
    NSString * _title;
    NSString * _description;
    NSURL    * _link;
    NSURL    * _imageURL;
    NSString * _date;
}

@end

@implementation MMParserRSS

static NSString * const rss         = @"rss";
static NSString * const item        = @"item";
static NSString * const enclosure   = @"enclosure";
static NSString * const title       = @"title";
static NSString * const pubDate     = @"pubDate";
static NSString * const linkRSS     = @"link";
static NSString * const description = @"description";
static NSString * const url         = @"url";
static NSString * const media       = @"media:content";

- (instancetype)init {
    if (self = [super init]) {
        _inProcess = NO;
        _updated   = NO;
    }
    return self;
}

- (NSMutableArray *)parsedItems {
    if (!_arrXMLData || _updated) {
        [self parse];
        _updated = NO;
    }
    return [NSMutableArray arrayWithArray:_arrXMLData];
}

- (void)setData:(NSData *)data {
    _updated = YES;
    _data    = data;
}

- (void)parse {
    if (_inProcess || !_data) {
        return;
    }
    
    _inProcess = YES;
    
    NSXMLParser *xmlparser = [[NSXMLParser new] initWithData:_data];
    
    [xmlparser setDelegate:self];
    [xmlparser parse];
    
    _inProcess = NO;
}

- (NSString *)scaneDescriptionForImage {
    NSString * withoutImage = @"";
    NSString * buffer       = @"";
    
    NSScanner * scanner = [NSScanner scannerWithString:_strXMLString];
    NSString * imageString;
    [scanner scanUpToString:@"img src=\"" intoString:&withoutImage];
    [scanner scanString:@"img src=\"" intoString:nil];
    [scanner scanUpToString:@"\"" intoString:&imageString];
    [scanner scanString:@"\"" intoString:nil];
    [scanner scanUpToString:@"]]>" intoString:&buffer];

    if (imageString) {
        _imageURL = [NSURL URLWithString:imageString];
    }
    
    NSString * result = [withoutImage stringByAppendingString:buffer];
    
    return result;
}

#pragma mark - Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:rss]) {
        _arrXMLData = [[NSMutableArray alloc] init];
    }
    if ([elementName isEqualToString:item]) {
        _title       = nil;
        _description = nil;
        _date        = nil;
        _link        = nil;
        _imageURL    = nil;
        _strXMLString = nil;
    }
    if ([elementName isEqualToString:enclosure]) {
        NSString *imageString = [attributeDict valueForKey:url];
        if (imageString) {
            _imageURL = [NSURL URLWithString:imageString];
        }
    }
    if ([elementName isEqualToString:media]) {
        NSString *imageString = [attributeDict valueForKey:url];
        if (imageString) {
            _imageURL = [NSURL URLWithString:imageString];
        }
    }
    _strXMLString = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!_strXMLString) {
        _strXMLString = [[NSMutableString alloc] init];
    }
    [_strXMLString appendString:string];    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:title]) {
        if (!_channelTitle) {
            _channelTitle = _strXMLString;
        } else {
            _title = _strXMLString;
        }
    } else if ([elementName isEqualToString:pubDate]) {
        _date = _strXMLString;
    } else if ([elementName isEqualToString:linkRSS]) {
        if (!_channelLink) {
            _channelLink = [NSURL URLWithString:_strXMLString];
        } else {
            _link = [NSURL URLWithString:_strXMLString];
        }
    } else if ([elementName isEqualToString:description]) {
        if (!_channelDescription) {
            _channelDescription = _strXMLString;
        } else {
            _description = [self scaneDescriptionForImage];
        }
    } else if ([elementName isEqualToString:item]) {
        [_arrXMLData addObject:[MMElementRSS createElementWithTitle:_title description:_description  date:_date link:_link andImageUrl:_imageURL]];
    }
}

@end
