//
//  NSData+Base64.m
//  MGSimpleNoteEngine
//
//  Created by Martin Gordon on 4/5/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import "NSData+Base64.h"

int encode(unsigned s_len, char *src, unsigned d_len, char *dst);

NSData *encodeData(NSData *input) {
	char encodeArray[512];
	memset(encodeArray, '\0', sizeof(encodeArray));
	
	encode([input length], (char *)[input bytes], sizeof(encodeArray), encodeArray);
	return [NSData dataWithBytes:encodeArray length:strlen(encodeArray)];
}


/**
 * The following is from:
 * http://davidjhinson.wordpress.com/2009/03/09/objective-c-and-http-basic-authentication/
 */

static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"abcdefghijklmnopqrstuvwxyz"
"0123456789"
"+/";

int encode(unsigned s_len, char *src, unsigned d_len, char *dst) {
	unsigned triad;
	
	for (triad = 0; triad < s_len; triad += 3) {
		unsigned long int sr;
		unsigned byte;
		
		for (byte = 0; (byte<3)&&(triad+byte<s_len); ++byte) {
			sr <<= 8;
			sr |= (*(src+triad+byte) & 0xff);
		}
		
		sr <<= (6-((8*byte)%6))%6; /*shift left to next 6bit alignment*/
		
		if (d_len < 4) return 1; /* error - dest too short */
		
		*(dst+0) = *(dst+1) = *(dst+2) = *(dst+3) = '=';
		switch(byte) {
			case 3:
				*(dst+3) = base64[sr&0x3f];
				sr >>= 6;
			case 2:
				*(dst+2) = base64[sr&0x3f];
				sr >>= 6;
			case 1:
				*(dst+1) = base64[sr&0x3f];
				sr >>= 6;
				*(dst+0) = base64[sr&0x3f];
		}
		dst += 4; d_len -= 4;
	}
	return 0;
}