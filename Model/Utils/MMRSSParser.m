//
//  MMRSSParser.m
//  RSS
//
//  Created by Marty on 13/05/2018.
//  Copyright © 2018 Marty. All rights reserved.
//

#import "MMRSSParser.h"
#import "MMRSSResource.h"
#import "MMRSSXMLResource.h"
#import "MMRSSXMLItem.h"
#import "NSDate+RFC.h"

@interface MMRSSXMLItemImpl: NSObject<MMRSSXMLItem>
@property NSString *title;
@property NSString *summary;
@property NSURL    *link;
@property NSData   *img;
@property NSDate   *pubDate;
@property NSURL    *imgUrl;
@end

@implementation MMRSSXMLItemImpl
@end

@interface MMRSSXMLResourceImpl: NSObject<MMRSSXMLResource>
@property NSString *title;
@property NSURL    *link;
@property NSMutableArray<id<MMRSSXMLItem>> *items;
@end

@implementation MMRSSXMLResourceImpl
@end

@interface MMRSSParser () <NSXMLParserDelegate>

@property MMRSSXMLResourceImpl *resource;
@property MMRSSXMLItemImpl     *item;
@property NSMutableString      *strXMLString;
@property NSString *channelDescription;
@property ParserSuccessBlock success;
@property ParserFailureBlock failure;
@property NSURL *urlResource;
@property BOOL resourceLinkLoaded;

@end

@implementation MMRSSParser

static NSString * const rss         = @"rss";
static NSString * const item        = @"item";
static NSString * const enclosure   = @"enclosure";
static NSString * const title       = @"title";
static NSString * const pubDate     = @"pubDate";
static NSString * const linkRSS     = @"link";
static NSString * const description = @"description";
static NSString * const url         = @"url";
static NSString * const media       = @"media:content";


- (void)parse:(NSData *)data withURL:(NSURL *)url success:(ParserSuccessBlock)success failure:(ParserFailureBlock)failure {
    _urlResource = url;
    _success = success;
    _failure = failure;
    
    NSXMLParser *xmlparser = [[NSXMLParser new] initWithData:data];
    [xmlparser setDelegate:self];
    [xmlparser parse];
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
        _item.imgUrl = [NSURL URLWithString:imageString];
    }
    
    NSString * result = [withoutImage stringByAppendingString:buffer];
    
    return result;
}

#pragma mark - Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:rss]) {
        _resource = [MMRSSXMLResourceImpl new];
        _resource.link = _urlResource;
    }
    if ([elementName isEqualToString:item]) {
        _item = [MMRSSXMLItemImpl new];
    }
    if ([elementName isEqualToString:enclosure]) {
        NSString *imageString = [attributeDict valueForKey:url];
        if (imageString) {
            _item.imgUrl = [NSURL URLWithString:imageString];
        }
    }
    if ([elementName isEqualToString:media]) {
        NSString *imageString = [attributeDict valueForKey:url];
        if (imageString) {
            _item.imgUrl = [NSURL URLWithString:imageString];
        }
    }
    _strXMLString = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!_strXMLString) {
        _strXMLString = [NSMutableString new];
    }
    [_strXMLString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:title]) {
        if (!_resource.title) {
            _resource.title = _strXMLString;
        } else {
            _item.title = _strXMLString;
        }
    } else if ([elementName isEqualToString:pubDate]) {
        _item.pubDate = [NSDate dateWithRFCString:_strXMLString format:ISDateFormatNone];
    } else if ([elementName isEqualToString:linkRSS]) {
        if (!_resourceLinkLoaded) {
            _resourceLinkLoaded = YES;
        } else {
            _item.link = [NSURL URLWithString:_strXMLString];
        }
    } else if ([elementName isEqualToString:description]) {
        if (!_channelDescription) {
            _channelDescription = _strXMLString;
        } else {
            _item.summary = [self scaneDescriptionForImage];
        }
    } else if ([elementName isEqualToString:item]) {
        if (_item.title && _item.link && _item.summary) {
            if (!_resource.items) {
                _resource.items = [NSMutableArray new];
            }
            [_resource.items addObject:_item];
        }
    } else if ([elementName isEqualToString:rss]) {
        if (_resource.title && _resource.link) {
            _success(_resource);
        } else {
            _failure();
        }
    }
    //TODO: надо будет предусмотреть такой исход. Rss в конце нет
}


@end
