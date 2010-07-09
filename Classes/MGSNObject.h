//
//  MGSNObject.h
//  MGSimplenoteEngine
//
//  Created by Martin Gordon on 4/6/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef int ActionID;
#define ActionNotFound -1

@class MGCallback;

@interface MGSNObject : NSObject {
	NSMutableArray *callbacks, *connections, *responses, *receivedData;
	NSString *authToken, *email;
	NSString *baseURLString;
}

@property (nonatomic, retain) NSMutableArray *callbacks, *connections, *responses, *receivedData;
@property (nonatomic, copy) NSString *authToken, *email;

// The base URL for all API calls.
- (NSString *)baseURLString;

// An array of @"key=value" strings containing the auth params (authToken and email).
- (NSArray *)authParams;

// Update the object's auth token and email with the values stored in the credential store.
- (void)updateCredentialsFromStore;

// Returns an NSError instance representing the error status of an NSHTTPURLResponse.
- (NSError *)errorForResponse:(NSHTTPURLResponse *)resp;

/**
 * Adds an object as an observer for the given selector. 
 * The selector must still be invoked separately. When it completes, it invokes the success or failure selector
 * on the observing object.
 *
 * The selectors must correspond to methods that a single NSNotification * argument:
 * - (void)observedSuccess:(NSNotification *)notif;
 */
- (void)addObserver:(id)obj forSelector:(SEL)selector success:(SEL)success failure:(SEL)failure;

/**
 * Posts the success/failure notifications for a given selector.
 */
- (void)postSuccessForSelector:(SEL)sel;
- (void)postFailureForSelector:(SEL)sel withError:(NSError *)error;

/**
 * Internal helper methods used to preserve state among different method calls.
 */
- (void)setCallback:(MGCallback *)callback forActionID:(ActionID)action;
- (void)setConnection:(NSURLConnection *)conn forActionID:(ActionID)action;
- (void)setResponse:(NSURLResponse *)resp forActionID:(ActionID)action;
- (void)setReceivedData:(NSData *)data forActionID:(ActionID)action;

- (void)callMethodWithActionID:(ActionID)actionID;

/**
 * Helper methods to location an ActionID for a given connection/data.
 */
- (ActionID)actionIDForConnection:(NSURLConnection *)conn;
- (ActionID)actionIDForData:(NSData *)data;


/**
 * Subclasses must implement these four methods.
 */

// Returns the number of actions this class supports.
- (NSInteger)actionCount;

// Returns the URL for the ActionID
- (NSURL *)URLForActionID:(ActionID)action;

// Returns the endpoint for the Action ID.
- (NSString *)endpointForActionID:(ActionID)action;

// Returns the HTTP Method for the ActionID (e.g., GET or POST).
- (NSString *)HTTPMethodForActionID:(ActionID)action;


/**
 * This method is optional for subclasses.
 * If a POST action is invoked, the body of the request is set to the return value of this method.
 */
- (NSData *)HTTPBodyForActionID:(ActionID)action;

@end
