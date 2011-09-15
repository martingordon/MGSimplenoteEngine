//
//  MGSimplenoteCredentialStore.h
//  MGSimpleNoteEngine
//
//  Created by Martin Gordon on 4/12/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MGSimplenoteLogin;

/**
 * This class represents an app-wide store (backed by NSUserDefaults) for Simplenote credentials.
 */

@interface MGSimplenoteCredentialStore : NSObject {
	
}

+ (NSString *)email;
+ (NSString *)password;
+ (NSString *)authToken;
+ (NSString *)appIdentifier; // e.g. MyApp/0.5.0

+ (void)setEmail:(NSString *)email;
+ (void)setPassword:(NSString *)password;
+ (void)setAuthToken:(NSString *)authToken;
+ (void)setAppIdentifier:(NSString *)identifier;


@end
