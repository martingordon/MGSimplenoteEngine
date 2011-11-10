//
//  NSString+URLEncode.m
//  MGSimplenoteEngine
//
//  Created by Matthias Hochgatterer on 26.10.11.
//  Copyright (c) 2011 selfcoded. All rights reserved.
//

#import "NSString+URLEncode.h"

@implementation NSString (URLEncode)

+ (NSString*)urlEncodedString:(NSString*)string{
    NSString *escapedString = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL,
																				 (CFStringRef)string,
																				 NULL,
																				 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				 kCFStringEncodingUTF8 );
	
	return escapedString;
}
- (NSString*)urlEncoded{
    NSString *escapedString = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL,
																				 (CFStringRef)self,
																				 NULL,
																				 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				 kCFStringEncodingUTF8 );
	
	return escapedString;
}

@end
