//
//  NSData+Base64.m
//  MGSimpleNoteEngine
//
//  Created by Martin Gordon on 4/5/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//  Rewritten 01-08-2011 by Mike Cohen to fix 512-byte truncation
//

#import "NSData+Base64.h"


/**
 * The following is from:
 * http://davidjhinson.wordpress.com/2009/03/09/objective-c-and-http-basic-authentication/
 */

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789"
"+/";

@implementation NSData (Base64)


+ (NSData*)Base64Encode: (NSString*)string
{
    NSMutableData *dst = nil;
    NSData *srcData = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (nil != srcData) {
        const unsigned char *srcBytes = [srcData bytes];
        unsigned srcLength = [srcData length];
        dst = [NSMutableData dataWithCapacity:srcLength];
        unsigned triad;
        
        for (triad = 0; triad < srcLength; triad += 3) {
            unsigned long int sr;
            unsigned byte;
            unsigned char tmp[4];
            
            for (byte = 0; (byte<3)&&(triad+byte<srcLength); ++byte) {
                sr <<= 8;
                sr |= (*(srcBytes+triad+byte) & 0xff);
            }
            
            sr <<= (6-((8*byte)%6))%6; /*shift left to next 6bit alignment*/
                        
            tmp[0] = tmp[1] = tmp[2] = tmp[3] = '=';
            switch(byte) {
                case 3:
                    tmp[3] = base64[sr&0x3f];
                    sr >>= 6;
                case 2:
                    tmp[2] = base64[sr&0x3f];
                    sr >>= 6;
                case 1:
                    tmp[1] = base64[sr&0x3f];
                    sr >>= 6;
                    tmp[0] = base64[sr&0x3f];
            }
            [dst appendBytes: tmp length: 4];
        }
    }
    return dst;
}

@end