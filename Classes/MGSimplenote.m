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
#import "SBJSON.h"

enum NoteActions {
	PullFromRemote = 0,
	PushToRemote,
	DeleteNote,
	ActionCount
};

@interface MGSimplenote ()

- (NSDictionary *)propertyToRespMapping;
- (NSString *)partialJSONRepresentation;
- (void)updateWithResponseDictionary:(NSDictionary *)dict;

@end

@implementation MGSimplenote

@synthesize key, text;
@synthesize modifyDate, createDate;
@synthesize deleted;

@synthesize syncNum, version, minVersion;
@synthesize shareKey, publishKey;
@synthesize systemTags, tags;

static NSDictionary *propertyToRespMapping = nil;

+ (id)noteWithDictionary:(NSDictionary *)dict {
	MGSimplenote *note = [[[MGSimplenote alloc] init] autorelease];
    [note updateWithResponseDictionary:dict];
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

- (NSDictionary *)propertyToRespMapping {
    if (!propertyToRespMapping) {
        propertyToRespMapping = [[NSDictionary dictionaryWithObjectsAndKeys:@"key", @"key",
                                 @"deleted", @"deleted",
                                 @"modifydate", @"modifyDate",
                                 @"createdate", @"createDate",
                                 @"syncnum", @"syncNum",
                                 @"version", @"version",
                                 @"minversion", @"minVersion",
                                 @"sharekey", @"shareKey",
                                 @"publishkey", @"publishKey",
                                 @"systemtags", @"systemTags",
                                 @"tags", @"tags",
                                 @"content", @"text",
                                 nil] retain];
    }
    return propertyToRespMapping;
}

- (NSString *)partialJSONRepresentation {
    NSArray *properties = [NSArray arrayWithObjects:@"deleted", @"modifyDate", @"createDate",
                           @"systemTags", @"tags", @"text", nil];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[properties count]];

    for (NSString *prop in properties) {
        id value = [self valueForKey:prop];

        if (([prop isEqualToString:@"modifyDate"] || [prop isEqualToString:@"createDate"]) && value != nil) {
            value = [NSNumber numberWithDouble:[[self valueForKey:prop] timeIntervalSince1970]];
        } else if ([prop isEqualToString:@"tags"] && value == nil) {
            value = [NSArray array];
        } else if ([prop isEqualToString:@"systemTags"] && value == nil) {
            value = [NSArray array];
        }

        if (value == nil) {
            value = [NSNull null];
        }
        [dict setObject:value forKey:[[self propertyToRespMapping] objectForKey:prop]];
    }

    SBJsonWriter *writer = [[SBJsonWriter alloc] init];
    NSString *json = [writer stringWithObject:dict];
    [writer release];

    return json;
}

- (void)updateWithResponseDictionary:(NSDictionary *)dict {
    for (NSString *prop in [[self propertyToRespMapping] allKeys]) {
        NSString *respKey = [[self propertyToRespMapping] objectForKey:prop];

        id value = nil;

        if ([prop isEqualToString:@"modifyDate"] || [prop isEqualToString:@"createDate"]) {
            value = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:respKey] doubleValue]];
        } else {
            value = [dict objectForKey:respKey];
        }

        if (value != nil && ![value isEqual:[NSNull null]]) {
            [self setValue:value forKey:prop];
        }
    }
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

    SBJSON *parser = [[SBJSON alloc] init];
	NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSDictionary *conts = [parser objectWithString:str];
	[str release];
    [parser release];

    [self updateWithResponseDictionary:conts];
	[self postSuccessForSelector:@selector(pullFromRemote)];
}


- (void)pushToRemoteSuccessWithResponse:(NSHTTPURLResponse *)resp data:(NSData *)data {
	if ([resp statusCode] != 200) {
		[self postFailureForSelector:@selector(pushToRemote) withError:[self errorForResponse:resp]];
		return;
	}

    SBJSON *parser = [[SBJSON alloc] init];
	NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSDictionary *conts = [parser objectWithString:str];
	[str release];
    [parser release];

    [self updateWithResponseDictionary:conts];
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
	
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@?%@", 
								 [self baseURLString], [self endpointForActionID:action], 
								 [params componentsJoinedByString:@"&"]]];
}


- (NSString *)endpointForActionID:(ActionID)action {
	switch (action) {
		case PullFromRemote:
			return [NSString stringWithFormat:@"data/%@", self.key];
		case PushToRemote:
            if (self.key == nil) {
                return @"data";
            } else {
                return [NSString stringWithFormat:@"data/%@", self.key];
            }
		case DeleteNote:
			return [NSString stringWithFormat:@"data/%@", self.key];
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
			return @"DELETE";
	}
	return [super HTTPMethodForActionID:action];
}

- (NSData *)HTTPBodyForActionID:(ActionID)action {
	switch (action) {
		case PushToRemote:
			return [[self partialJSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
    }
	return [super HTTPBodyForActionID:action];
}


@end
