//
//  MGSimplenoteLogin.h
//  MGSimplenoteEngine
//
//  Created by Martin Gordon on 4/5/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MGSNObject.h"


/**
 * This class represents a login object which can be used to authenticate the user and retrieve an auth token,
 * which is then saved automatically to the NSUserDefault-backed MGSimplenoteCredentialStore.
 *
 * Sample usage:
 *   MGSimplenoteLogin *login = [[MGSimplenoteLogin alloc] init];
 *   login.email = @"test@example.com";
 *   login.pasword = @"password";
 *   [login addObserver:self forSelector:@selector(login) 
 *	            success:@selector(showSuccessMsg:) failure:@selector(showFailureMsg:)];
 *   [login login];
 */
@interface MGSimplenoteLogin : MGSNObject {
	NSString *password;
}

@property (nonatomic, copy) NSString *password;

/**
 * Initiates an asynchronous login call.
 */
- (void)login;

@end
