//
//  MGCallback.m
//  MGSimplenoteEngine
//
//  Created by Martin Gordon on 4/5/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import "MGCallback.h"


@implementation MGCallback

@synthesize target, success, failure;

- (void)invokeSuccessWithResponse:(NSURLResponse *)resp data:(NSData *)data {
	if ([target respondsToSelector:success]) {
		[target performSelector:success withObject:resp withObject:data];
	}
}

- (void)invokeFailure:(NSError *)error {
	if ([target respondsToSelector:failure]) {
		[target performSelector:failure withObject:error];
	}	
}

@end
