//
//  FRParseLogger.m
//
//  Created by Jonathan Dalrymple on 19/06/2012.
//  Copyright (c) 2012 Float:Right Ltd. All rights reserved.
//

#import "FRParseLogger.h"
#import <Parse/Parse.h>

@interface FRParseLogger (){
	NSDateFormatter *dateFormatter_;
}

@end

@implementation FRParseLogger

static FRParseLogger *sharedLogger;

+ (void)initialize
{
	static BOOL initialized = NO;
	if (!initialized)
	{
		initialized = YES;
		
		sharedLogger = [[FRParseLogger alloc] init];
	}
}

+(id) sharedInstance{
	return sharedLogger;
}

- (id)init
{
	if (sharedLogger != nil)
	{
		return nil;
	}
	
	return self;
}

-(NSDateFormatter*) dateFormatter{
	
	if( !dateFormatter_ ){
		dateFormatter_ = [[NSDateFormatter alloc] init];
		[dateFormatter_ setFormatterBehavior:NSDateFormatterBehavior10_4];
		[dateFormatter_ setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
	}
	
	return dateFormatter_;
}

- (void)logMessage:(DDLogMessage *) logMessage{
	
	NSString *logMsg = logMessage->logMsg;
	
	if (self->formatter) {
		logMsg = [self->formatter formatLogMessage:logMessage];
	}
	
	if (logMsg) {
		PFObject *obj;
		
		obj = [PFObject objectWithClassName:@"FRParseLogger"];
		
		[obj setObject:logMsg
				forKey:@"message"];
		
		[obj setObject:[PFInstallation currentInstallation].objectId
				forKey:@"installation"];
		
		[obj setObject:[[NSString stringWithUTF8String: logMessage->file] lastPathComponent]
				forKey:@"file"];
		
		[obj setObject:[NSString stringWithUTF8String:logMessage->function]
				forKey:@"method"];
		
		[obj setObject:[[NSNumber numberWithInt:logMessage->lineNumber] stringValue]
				forKey:@"line"];
		
		[obj saveEventually];
	}
}

- (NSString *)loggerName{
	return @"com.floatright.ParseLogger";
}

@end
