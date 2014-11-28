//
//  PASAssertionHandler.m
//  Passions
//
//  Created by Simon Tännler on 21/11/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAssertionHandler.h"
#import <Parse/Parse.h>

@implementation PASAssertionHandler

-(void)handleFailureInFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format, ...
{
	NSString *file = [[NSURL URLWithString:fileName] lastPathComponent];
	NSString *location =  [NSString stringWithFormat:@"%@:%i", file, line];
	
#if DEBUG
	CLSNSLog(@"Assertion failure: FUNCTION = (%@) at (%@), %@", functionName, location, format);
	[super handleFailureInFunction:functionName file:fileName lineNumber:line description:format, @""];
#else
	// don't crash in production, just log
	CLSLog(@"Assertion failure: FUNCTION = (%@) at (%@), %@", functionName, location, format);
#endif
}

-(void)handleFailureInMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(NSInteger)line description:(NSString *)format, ...
{
	NSString *methodName = NSStringFromSelector(selector);
	NSString *file = [[NSURL URLWithString:fileName] lastPathComponent];
	NSString *location =  [NSString stringWithFormat:@"%@:%i", file, line];
	
#if DEBUG
	CLSNSLog(@"Assertion failure: METHOD = (%@) for object = (%@) at (%@), %@", methodName, object, location, format);
	[super handleFailureInMethod:selector object:object file:fileName lineNumber:line description:format, @""];
#else
	// don't crash in production, just log
	CLSLog(@"Assertion failure: METHOD = (%@) for object = (%@) at (%@), %@", methodName, object, location, format);
#endif
}

@end
