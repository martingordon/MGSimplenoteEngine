//
//  MGSimplenoteCredentialStore.m
//  MGSimpleNoteEngine
//
//  Created by Martin Gordon on 4/12/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import "MGSimplenoteCredentialStore.h"
#import "MGSimplenoteLogin.h"

@implementation MGSimplenoteCredentialStore

+ (id)defaultValueForKey:(NSString *)key {
	return [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"simplenote-%@", key]];
}

+ (void)setDefaultValue:(id)value forKey:(NSString *)key {
	[[NSUserDefaults standardUserDefaults] setValue:value forKey:[NSString stringWithFormat:@"simplenote-%@", key]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)email {
	return [self defaultValueForKey:NSStringFromSelector(_cmd)];
}

+ (NSString *)password {
	return [self defaultValueForKey:NSStringFromSelector(_cmd)];
}

+ (NSString *)authToken {
	return [self defaultValueForKey:NSStringFromSelector(_cmd)];
}

+ (NSString *)appIdentifier {
	return [self defaultValueForKey:NSStringFromSelector(_cmd)];
}

+ (void)setEmail:(NSString *)val {
	NSString *sel = NSStringFromSelector(_cmd);
	NSString *key = [sel substringWithRange:NSMakeRange(3, [sel length]-4)];
	key = [NSString stringWithFormat:@"%@%@", [[key substringToIndex:1] lowercaseString],
		   [key substringFromIndex:1]];
	[self setDefaultValue:val forKey:key];
}

+ (void)setPassword:(NSString *)val {
	NSString *sel = NSStringFromSelector(_cmd);
	NSString *key = [sel substringWithRange:NSMakeRange(3, [sel length]-4)];
	key = [NSString stringWithFormat:@"%@%@", [[key substringToIndex:1] lowercaseString],
		   [key substringFromIndex:1]];
	[self setDefaultValue:val forKey:key];
}

+ (void)setAuthToken:(NSString *)val {
	NSString *sel = NSStringFromSelector(_cmd);
	NSString *key = [sel substringWithRange:NSMakeRange(3, [sel length]-4)];
	key = [NSString stringWithFormat:@"%@%@", [[key substringToIndex:1] lowercaseString],
		   [key substringFromIndex:1]];
	[self setDefaultValue:val forKey:key];
}

+ (void)setAppIdentifier:(NSString *)val{
	NSString *sel = NSStringFromSelector(_cmd);
	NSString *key = [sel substringWithRange:NSMakeRange(3, [sel length]-4)];
	key = [NSString stringWithFormat:@"%@%@", [[key substringToIndex:1] lowercaseString],
		   [key substringFromIndex:1]];
	[self setDefaultValue:val forKey:key];	
}

@end
