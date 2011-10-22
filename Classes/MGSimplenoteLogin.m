//
//  MGSimplenoteLogin.m
//  MGSimplenoteEngine
//
//  Created by Martin Gordon on 4/5/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import "MGSimplenoteLogin.h"
#import "MGCallback.h"
#import "MGSimplenoteCredentialStore.h"
#import "NSData+Base64.h"

enum LoginActions {
	Login = 0,
	ActionCount
};

@interface MGSimplenoteLogin (Internal)

- (void)loginSuccessWithResponse:(NSURLResponse *)resp data:(NSData *)data;
- (void)loginFailure:(NSError *)error;

@end


@implementation MGSimplenoteLogin

@synthesize password;

- (id)init {
	self = [super init];
	if (self != nil) {
		MGCallback *callback = [[MGCallback alloc] init];
		callback.target = self;
		callback.success = @selector(loginSuccessWithResponse:data:);
		callback.failure = @selector(loginFailure:);
		
		[self setCallback:callback forActionID:Login];
		[callback release];
	}
	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@ authToken:%@>", [super description], self.authToken];
}

- (NSString *)baseURLString {
    return @"https://simple-note.appspot.com/api";
}

- (void)loginSuccessWithResponse:(NSURLResponse *)resp data:(NSData *)data {
	if ([data length] != 0) {
		NSString *token = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		self.authToken = token;
		[token release];
		
		[self postSuccessForSelector:@selector(login)];
	} else {
		NSError *error = [NSError errorWithDomain:@"MGSimplenoteLoginDomain" code:0 
										 userInfo:[NSDictionary dictionaryWithObject:@"Unknown login error. Check user name and password." forKey:NSLocalizedDescriptionKey]];
		[self loginFailure:error];
	}
}


- (void)loginFailure:(NSError *)error {
	[self postFailureForSelector:@selector(login) withError:error];
}


- (NSInteger)actionCount {
	return ActionCount;
}

- (NSURL *)URLForActionID:(ActionID)action {
	if (action == Login) {
		return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [self baseURLString], [self endpointForActionID:action]]];
	}
	return [super URLForActionID:action];
}

- (NSString *)endpointForActionID:(ActionID)action {
	if (action == Login) {
		return @"login";
	}
	return [super endpointForActionID:action];
}

- (NSString *)HTTPMethodForActionID:(ActionID)action {
	if (action == Login) {
		return @"POST";
	}
	return [super HTTPMethodForActionID:action];
}

- (NSData *)HTTPBodyForActionID:(ActionID)action {
	if (action == Login) {
        return [NSData base64Encode:[NSString stringWithFormat:@"email=%@&password=%@", self.email, self.password]];
	}
	return [super HTTPBodyForActionID:action];
}


- (void)login {
    NSAssert(password && [password length] > 0, @"Password has to be set!");
	[self callMethodWithActionID:Login];
}

@end