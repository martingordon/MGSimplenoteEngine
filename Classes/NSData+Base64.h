//
//  NSData+Base64.h
//  MGSimpleNoteEngine
//
//  Created by Martin Gordon on 4/5/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//  Rewritten 01-08-2011 by Mike Cohen
//

#import <Foundation/Foundation.h>

@interface NSData(Base64)

+ (NSData *)base64Encode:(NSString *)string;

@end