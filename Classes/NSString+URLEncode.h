//
//  NSString+URLEncode.h
//  MGSimplenoteEngine
//
//  Created by Matthias Hochgatterer on 26.10.11.
//  Copyright (c) 2011 selfcoded. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncode)

+ (NSString*)urlEncodedString:(NSString*)string;
- (NSString*)urlEncoded;

@end
