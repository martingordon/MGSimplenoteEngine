//
//  MGSimplenoteIndex.m
//  MGSimplenoteEngine
//
//  Created by Martin Gordon on 4/5/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import "MGSimplenoteIndex.h"
#import "MGCallback.h"
#import "MGSimplenote.h"
#import "JSON.h"

enum IndexActions {
	PullFromRemote = 0,
	ActionCount
};

@interface MGSimplenoteIndex (Internal)

- (void)pullFromRemoteSuccessWithResponse:(NSHTTPURLResponse *)resp data:(NSData *)data;
- (void)pullFromRemoteFailure:(NSError *)error;

@end


@implementation MGSimplenoteIndex

@synthesize contents, fullContents;

- (id)init {
	self = [super init];
	if (self != nil) {
		MGCallback *callback = [[MGCallback alloc] init];
		callback.target = self;
		callback.success = @selector(pullFromRemoteSuccessWithResponse:data:);
		callback.failure = @selector(pullFromRemoteFailure:);
		
		[self setCallback:callback forActionID:PullFromRemote];
		[callback release];
	}
	return self;
}


- (void)pullFromRemote {
	[self callMethodWithActionID:PullFromRemote];
}


- (void)pullFromRemoteSuccessWithResponse:(NSHTTPURLResponse *)resp data:(NSData *)data {
	if ([resp statusCode] != 200) {
		[self pullFromRemoteFailure:[self errorForResponse:resp]];
		return;
	}
	NSError *error = nil;
	SBJSON *parser = [[SBJSON alloc] init];
	NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSArray *conts = [parser objectWithString:str];
	[str release];
	
	if (error == nil) {
		NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[conts count]];
		
		for (NSDictionary *obj in conts) {
			[tempArray addObject:[MGSimplenote noteWithDictionary:obj]];
		}
		[contents release];
		contents = [tempArray retain];
		[self postSuccessForSelector:@selector(pullFromRemote)];
	} else {
		[self pullFromRemoteFailure:error];
	}
}

- (void)pullFromRemoteFailure:(NSError *)error {
	[self postFailureForSelector:@selector(pullFromRemote) withError:error];
}


- (NSInteger)actionCount {
	return ActionCount;
}

- (NSURL *)URLForActionID:(ActionID)action {
	NSMutableArray *params = [NSMutableArray arrayWithArray:[self authParams]];
	
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@", 
								 [self baseURLString], [self endpointForActionID:action], 
								 [params componentsJoinedByString:@"&"]]];
}

- (NSString *)endpointForActionID:(ActionID)action {
	switch (action) {
		case PullFromRemote:
			return @"index";
	}
	return [super endpointForActionID:action];
	
}

- (NSString *)HTTPMethodForActionID:(ActionID)action {
	switch (action) {
		case PullFromRemote:
			return @"GET";
	}
	return [super HTTPMethodForActionID:action];
}


@end
