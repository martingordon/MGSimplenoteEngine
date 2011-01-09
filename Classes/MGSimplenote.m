//
//  MGSimplenote.m
//  MGSimplenoteEngine
//
//  Created by Martin Gordon on 4/5/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import "MGSimplenote.h"
#import "MGCallback.h"
#import "NSData+Base64.h"

enum NoteActions {
	PullFromRemote = 0,
	PushToRemote,
	DeleteNote,
	ActionCount
};

@implementation MGSimplenote

@synthesize key, text;
@synthesize modifyDate, createDate;
@synthesize deleted;

+ (id)noteWithDictionary:(NSDictionary *)dict {
	MGSimplenote *note = [[[MGSimplenote alloc] init] autorelease];
	note.key = [dict objectForKey:@"key"];
	note.text = [dict objectForKey:@"text"];

	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"y'-'MM'-'dd HH':'mm':'ss'.'SSSSSS"];
	
	if ([dict objectForKey:@"modify"] != nil) {
		note.modifyDate = [formatter dateFromString:[dict objectForKey:@"modify"]];		
	}
	if ([dict objectForKey:@"create"] != nil) {
		note.createDate = [formatter dateFromString:[dict objectForKey:@"create"]];		
	}
	[formatter release];
	note.deleted = [dict objectForKey:@"deleted"];
	return note;
}

- (id)init {
	self = [super init];
	if (self != nil) {
		MGCallback *callback = [[MGCallback alloc] init];
		callback.target = self;
		callback.success = @selector(pullFromRemoteSuccessWithResponse:data:);
		callback.failure = @selector(pullFromRemoteFailure:);
		[self setCallback:callback forActionID:PullFromRemote];
		[callback release];
		
		callback = [[MGCallback alloc] init];
		callback.target = self;
		callback.success = @selector(pushToRemoteSuccessWithResponse:data:);
		callback.failure = @selector(pushToRemoteFailure:);
		[self setCallback:callback forActionID:PushToRemote];
		[callback release];
		
		callback = [[MGCallback alloc] init];
		callback.target = self;
		callback.success = @selector(deleteNoteSuccessWithResponse:data:);
		callback.failure = @selector(deleteNoteFailure:);
		[self setCallback:callback forActionID:DeleteNote];
		[callback release];
	}
	return self;
}

- (void)dealloc {
	[key release];
	[text release];
	[modifyDate release];
	[createDate release];
	[deleted release];
	
	[super dealloc];
}

- (void)pullFromRemote {
	[self callMethodWithActionID:PullFromRemote];
}

- (void)pushToRemote {
	[self callMethodWithActionID:PushToRemote];
}

- (void)deleteNote {
	[self callMethodWithActionID:DeleteNote];
}


- (void)pullFromRemoteSuccessWithResponse:(NSHTTPURLResponse *)resp data:(NSData *)data {
	if ([resp statusCode] != 200) {
		[self postFailureForSelector:@selector(pullFromRemote) withError:[self errorForResponse:resp]];
		return;
	}
	NSDictionary *headers = [resp allHeaderFields];
	
	self.key = [headers objectForKey:@"Note-Key"];
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"y'-'MM'-'dd HH':'mm':'ss'.'SSSSSS"];
	
	if ([headers objectForKey:@"Note-Modifydate"] != nil) {
		self.modifyDate = [formatter dateFromString:[headers objectForKey:@"Note-Modifydate"]];
	}
	if ([headers objectForKey:@"Note-Createdate"] != nil) {
		self.createDate = [formatter dateFromString:[headers objectForKey:@"Note-Createdate"]];
	}
	[formatter release];
	
	self.deleted = [headers objectForKey:@"Note-Deleted"];
	
	NSString *incomingText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	self.text = incomingText;
	[incomingText release];
	
	[self postSuccessForSelector:@selector(pullFromRemote)];
}


- (void)pushToRemoteSuccessWithResponse:(NSHTTPURLResponse *)resp data:(NSData *)data {
	if ([resp statusCode] != 200) {
		[self postFailureForSelector:@selector(pushToRemote) withError:[self errorForResponse:resp]];
		return;
	}
	[self postSuccessForSelector:@selector(pushToRemote)];	
}


- (void)deleteNoteSuccessWithResponse:(NSHTTPURLResponse *)resp data:(NSData *)data {
	if ([resp statusCode] != 200) {
		[self postFailureForSelector:@selector(deleteNote) withError:[self errorForResponse:resp]];
		return;
	}
	[self postSuccessForSelector:@selector(deleteNote)];
}


- (void)pullFromRemoteFailure:(NSError *)error {
	NSString *selString = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"Failure" withString:@""];
	[self postFailureForSelector:NSSelectorFromString(selString) withError:error];
}


- (void)pushToRemoteFailure:(NSError *)error {
	NSString *selString = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"Failure" withString:@""];
	[self postFailureForSelector:NSSelectorFromString(selString) withError:error];	
}


- (void)deleteNoteFailure:(NSError *)error {
	NSString *selString = [NSStringFromSelector(_cmd) stringByReplacingOccurrencesOfString:@"Failure" withString:@""];
	[self postFailureForSelector:NSSelectorFromString(selString) withError:error];
}


#pragma mark -
#pragma mark Action Helpers

- (NSInteger)actionCount {
	return ActionCount;
}

- (NSURL *)URLForActionID:(ActionID)action {
	NSMutableArray *params = [NSMutableArray arrayWithArray:[self authParams]];
	
	if (self.key) {
		[params addObject:[NSString stringWithFormat:@"key=%@", self.key]];
	}
	
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@", 
								 [self baseURLString], [self endpointForActionID:action], 
								 [params componentsJoinedByString:@"&"]]];
}


- (NSString *)endpointForActionID:(ActionID)action {
	switch (action) {
		case PullFromRemote:
			return @"note";
		case PushToRemote:
			return @"note";
		case DeleteNote:
			return @"delete";
	}
	return [super endpointForActionID:action];
}


- (NSString *)HTTPMethodForActionID:(ActionID)action {
	switch (action) {
		case PullFromRemote:
			return @"GET";
		case PushToRemote:
			return @"POST";
		case DeleteNote:
			return @"GET";
	}
	return [super HTTPMethodForActionID:action];
}


- (NSData *)HTTPBodyForActionID:(ActionID)action {
	switch (action) {
		case PushToRemote:
//			return encodeData([self.text dataUsingEncoding:NSUTF8StringEncoding]);
			return [NSData Base64Encode: self.text];
	}
	return [super HTTPBodyForActionID:action];
}


@end
