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
    
    NSURL           * _imageURL;
    NSString        * _title;
    NSString        * _description;
    NSString        * _date;
}

@end

@implementation MMParserRSS

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

- (void)scaneDescriptionForImage {
    NSScanner *scanner = [NSScanner scannerWithString:_strXMLString];
    NSString *imageString;
    [scanner scanUpToString:@"img src=\"" intoString:nil];
    [scanner scanString:@"img src=\"" intoString:nil];
    [scanner scanUpToString:@"\"" intoString:&imageString];
    [scanner scanUpToString:@"]]>" intoString:nil];

    if (imageString) {
        _imageURL = [NSURL URLWithString:imageString];
    }
}

#pragma mark - Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"rss"]) {
        _arrXMLData = [[NSMutableArray alloc] init];
    } else if ([elementName isEqualToString:@"item"]) {
        _title       = nil;
        _description = nil;
        _date        = nil;
        _imageURL    = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!_strXMLString) {
        _strXMLString = [[NSMutableString alloc] initWithString:string];
    } else {
        [_strXMLString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"title"]) {
        _title = _strXMLString;
    }
    if ([elementName isEqualToString:@"pubDate"]) {
        _date = _strXMLString;
    }
    if ([elementName isEqualToString:@"description"]) {
        _description = _strXMLString;
        [self scaneDescriptionForImage];
    }
    if ([elementName isEqualToString:@"item"]) {
        [_arrXMLData addObject:[MMElementRSS createElementWithTitle:_title description:_description  date:_date andImageUrl:_imageURL]];
    }
    _strXMLString = nil;
}

@end
