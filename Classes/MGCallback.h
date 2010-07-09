//
//  MGCallback.h
//  MGSimplenoteEngine
//
//  Created by Martin Gordon on 4/5/10.
//  Copyright 2010 Martin Gordon. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * This class represents a wrapper for a pair of selectors to call on an object.
 *
 * The two selectors must match the signatures for this class's -invokeSuccessWithResponse: and -invokeFailure:
 * methods.
 *
 * TODO: Create a subclass that accepts blocks instead of selectors.
 */
@interface MGCallback : NSObject {
	id target;
	SEL success, failure;
}

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL success, failure;

- (void)invokeSuccessWithResponse:(NSURLResponse *)resp data:(NSData *)data;
- (void)invokeFailure:(NSError *)error;

@end
