//
//  MGSNObject.m
//  MGSimplenoteEngine
//
//  Created by Martin Gordon on 4/6/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import "MGSNObject.h"
#import "MGCallback.h"
#import "MGSimplenoteCredentialStore.h"

enum MGSNObjectActions {
	ActionCount = 0
};

@implementation MGSNObject

@synthesize callbacks, connections, responses, receivedData;
@synthesize authToken, email;

- (id)init {
	self = [super init];
	if (self != nil) {
		NSMutableArray *nullArray = [NSMutableArray arrayWithCapacity:[self actionCount]];
		for (int i=0; i < [self actionCount]; i++) {
			[nullArray addObject:[NSNull null]];
		}
		
		callbacks = [[NSMutableArray arrayWithArray:nullArray] retain];
		connections = [[NSMutableArray arrayWithArray:nullArray] retain];
		responses = [[NSMutableArray arrayWithArray:nullArray] retain];
		receivedData = [[NSMutableArray arrayWithArray:nullArray] retain];
		[self updateCredentialsFromStore];
	}
	return self;
}

- (void)updateCredentialsFromStore {
	authToken = [[MGSimplenoteCredentialStore authToken] retain];
	email = [[MGSimplenoteCredentialStore email] retain];	
}


- (NSString *)baseURLString {
	return @"https://simple-note.appspot.com/api";
}


- (NSArray *)authParams {
	return [NSArray arrayWithObjects:[NSString stringWithFormat:@"auth=%@", self.authToken],
			[NSString stringWithFormat:@"email=%@", self.email], nil];
}


- (NSString *)successNotificationNameForSelector:(SEL)selector {
	NSString *selString = [NSString stringWithFormat:@"%@%@",
						   [[NSStringFromSelector(selector) substringToIndex:1] capitalizedString],
						   [NSStringFromSelector(selector) substringFromIndex:1]];
	
	return [NSString stringWithFormat:@"%@%@SuccessNotification", NSStringFromClass([self class]), selString];
}


- (NSString *)failureNotificationNameForSelector:(SEL)selector {
	NSString *selString = [NSString stringWithFormat:@"%@%@",
						   [[NSStringFromSelector(selector) substringToIndex:1] capitalizedString],
						   [NSStringFromSelector(selector) substringFromIndex:1]];
							
	return [NSString stringWithFormat:@"%@%@FailureNotification", NSStringFromClass([self class]), selString];
}


- (NSError *)errorForResponse:(NSHTTPURLResponse *)resp {
	NSError *error = [NSError errorWithDomain:@"MGSimplenoteErrorDomain" 
										 code:[resp statusCode] 
									 userInfo:[NSDictionary dictionaryWithObject:
											   [NSHTTPURLResponse localizedStringForStatusCode:[resp statusCode]]
																		  forKey:NSLocalizedDescriptionKey]];
	return error;
}


- (void)addObserver:(id)obj forSelector:(SEL)selector success:(SEL)success failure:(SEL)failure {
	[[NSNotificationCenter defaultCenter] addObserver:obj selector:success name:[self successNotificationNameForSelector:selector] object:self];
	[[NSNotificationCenter defaultCenter] addObserver:obj selector:failure name:[self failureNotificationNameForSelector:selector] object:self];
}


- (void)postSuccessForSelector:(SEL)sel {
	[[NSNotificationCenter defaultCenter] postNotificationName:[self successNotificationNameForSelector:sel] object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, NSStringFromClass([self class]), nil]];
}


- (void)postFailureForSelector:(SEL)sel withError:(NSError *)error {
	[[NSNotificationCenter defaultCenter] postNotificationName:[self failureNotificationNameForSelector:sel] object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, NSStringFromClass([self class]), error, @"error", nil]];
}


- (void)setCallback:(MGCallback *)callback forActionID:(ActionID)action {
	if (action < [self actionCount]) {
		id obj = callback;
		if (obj == nil) {
			obj = [NSNull null];
		}
		[callbacks replaceObjectAtIndex:action withObject:obj];
	}
}


- (void)setConnection:(NSURLConnection *)conn forActionID:(ActionID)action {
	if (action < [self actionCount]) {
		id obj = conn;
		if (obj == nil) {
			obj = [NSNull null];
		}
		[connections replaceObjectAtIndex:action withObject:obj];
	}	
}

- (void)setResponse:(NSURLResponse *)resp forActionID:(ActionID)action {
	if (action < [self actionCount]) {
		id obj = resp;
		if (obj == nil) {
			obj = [NSNull null];
		}
		[responses replaceObjectAtIndex:action withObject:obj];
	}	
}

- (void)setReceivedData:(NSData *)data forActionID:(ActionID)action {
	if (action < [self actionCount]) {
		id obj = data;
		if (obj == nil) {
			obj = [NSNull null];
		}
		[receivedData replaceObjectAtIndex:action withObject:obj];
	}
}

- (NSInteger)actionCount {
	return ActionCount;
}

- (NSURL *)URLForActionID:(ActionID)action {
	return nil;
}

- (NSString *)endpointForActionID:(ActionID)action {
	return nil;
}

- (NSString *)HTTPMethodForActionID:(ActionID)action {
	return nil;
}

- (NSData *)HTTPBodyForActionID:(ActionID)action {
	return nil;
}

- (void)callMethodWithActionID:(ActionID)action {
	NSURL *URL = [self URLForActionID:action];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:URL];
	[req setHTTPMethod:[self HTTPMethodForActionID:action]];
	[req setHTTPBody:[self HTTPBodyForActionID:action]];
	
	[self setReceivedData:[NSMutableData data] forActionID:action];
	[self setConnection:[NSURLConnection connectionWithRequest:req delegate:self] forActionID:action];
	[[connections objectAtIndex:action] start];
}


#pragma mark -
#pragma mark NSURLConnection methods

- (ActionID)actionIDForConnection:(NSURLConnection *)conn {
	for (int i=0; i < [self actionCount]; i++) {
		if (conn == [connections objectAtIndex:i]) {
			return i;
		}
	}
	return ActionNotFound;
}

- (ActionID)actionIDForData:(NSData *)data {
	for (int i=0; i < [self actionCount]; i++) {
		if (data == [receivedData objectAtIndex:i]) {
			return i;
		}
	}
	return ActionNotFound;
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	ActionID actionID = [self actionIDForConnection:connection];
	
	if (actionID != ActionNotFound) {
		[self setResponse:(NSHTTPURLResponse *)response forActionID:actionID];
		[[receivedData objectAtIndex:actionID] setLength:0];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	ActionID actionID = [self actionIDForConnection:connection];
	
	if (actionID != ActionNotFound) {
		[[receivedData objectAtIndex:actionID] appendData:data];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	ActionID actionID = [self actionIDForConnection:connection];
	
	if (actionID != ActionNotFound) {
		[self setReceivedData:nil forActionID:actionID];
		[[callbacks objectAtIndex:actionID] invokeFailure:error];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	ActionID actionID = [self actionIDForConnection:connection];
	
	if (actionID != ActionNotFound) {
		NSData *data = [[[receivedData objectAtIndex:actionID] retain] autorelease];
		NSURLResponse *resp = [[[responses objectAtIndex:actionID] retain] autorelease];
		[self setReceivedData:nil forActionID:actionID];
		[self setResponse:nil forActionID:actionID];
		[[callbacks objectAtIndex:actionID] invokeSuccessWithResponse:resp data:data];
	}
}


@end
