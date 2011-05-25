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
@synthesize length, mark, since;

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
	NSDictionary *conts = [parser objectWithString:str];
	[str release];
    [parser release];
	
	if (error == nil) {
        NSArray *data = [conts objectForKey:@"data"];
		NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[data count]];
		
		for (NSDictionary *obj in data) {
			[tempArray addObject:[MGSimplenote noteWithDictionary:obj]];
		}
		[contents release];
		contents = [tempArray retain];

        self.mark = [conts objectForKey:@"mark"];
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

    if (self.since) {
        [params addObject:[NSString stringWithFormat:@"since=%.5f", [self.since timeIntervalSince1970]]];
    }

    if (self.mark) {
        [params addObject:[NSString stringWithFormat:@"mark=%@", self.mark]];
    }

    if (self.length > 0) {
        [params addObject:[NSString stringWithFormat:@"length=%d", self.length]];
    }

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
