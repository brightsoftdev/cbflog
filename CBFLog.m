/* 
 * CBFLog is a singleton logging object for more powerful logging in your cocoa projects
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * CBFLog.m
 * 
 * Created by Camron Flanders on 2.23.09
 * Copyright 2009 camronflanders. All rights reserved.
 * 
 */

#import "CBFLog.h"


@implementation CBFLog

#pragma mark -
#pragma mark SINGLETON STUFF

static CBFLog *sharedDebug = nil;
static NSArray *severityLevels = nil;

static NSString *outputLevelStringFormat = @"[%@] ";
static NSString *fileNameStringFormat = @"%@:";
static NSString *lineNumberStringFormat = @"%d ";
static NSString *functionNameStringFormat = @"%s | ";
static NSString *blankString = @"";

+ (CBFLog *) sharedDebug
{
	return sharedDebug;
}

+ (void)initialize
{
	
	if(!sharedDebug) 
		sharedDebug = [[self alloc] init];
	
	if(severityLevels == nil)
		severityLevels = [[NSArray alloc] initWithObjects:	@"CRITICAL", 
															@" ERROR  ", 
															@"WARNING ", 
															@" NOTIFY ",
															@"  INFO  ", 
															@" DEBUG  ", nil];	
}

+ (id) allocWithZone:(NSZone *) zone
{
	if (sharedDebug) 
	{
		//The caller expects to receive a new object, so implicitly retain it to balance out the caller's eventual release message.
		return [sharedDebug retain];
	}
	else
	{
		//When not already set, +initialize is our caller—it's creating the shared instance. Let this go through.
		return [super allocWithZone:zone];
	}
	return nil;
}

- (id) init {
    if (!hasInited) 
	{
        if ((self = [super init])) 
		{
            hasInited = YES;
        }
    }

    return self;
}

#pragma mark -
#pragma mark debug methods
- (void)log:(int)severity overrideGlobal:(BOOL)override fileName:(char *)file lineNumber:(int)line functionName:(const char *)funcNameString input:(NSString *)message, ...
{
	// check to see if we have disabled debugging globally and return unless
	// we want to override the global setting for this statment.
	if(!GLOBAL_SOFT_ENABLE && !override) return;
	
	// if we are below our threshold, return
	if(severity > LOG_LEVEL) return;
	
	va_list argList;
	va_start(argList, message);
	NSString *messageString = [[[NSString alloc] initWithFormat:message 
													  arguments:argList] autorelease];
	va_end(argList);
	

	NSString *logString;
	if(!BARE_OUTPUT)
	{
		NSString *filePath;
		NSString *outputLevelString;
		NSString *lineString;
		NSString *functionNameString;
		
		if(LOG_SEVERITY)
		{
			int outputLevel = (severity) ? severity : 0;
			outputLevelString = [NSString stringWithString:[severityLevels objectAtIndex:outputLevel]];
			outputLevelString = [NSString stringWithFormat:outputLevelStringFormat, outputLevelString];
		} else
			outputLevelString = blankString;

		if(LOG_PATH)
		{
			filePath = [[[NSString alloc] initWithBytes:file 
												 length:strlen(file) 
											   encoding:NSUTF8StringEncoding] autorelease];
			if(!LOG_FULL_PATH)
				filePath = [filePath lastPathComponent];
			
			filePath = [NSString stringWithFormat:fileNameStringFormat, filePath];
		} else
			filePath = blankString;
		
		if(LOG_LINE_NUM)
			lineString = [NSString stringWithFormat:lineNumberStringFormat, line];
		else
			lineString = blankString;
		
		if(LOG_FUNC_NAME)
			functionNameString = [NSString stringWithFormat:functionNameStringFormat, funcNameString];
		else
			functionNameString = blankString;
		
		logString = [[[NSString alloc] initWithFormat:@"%@%@%@%@%@", outputLevelString,
																	filePath, 
																	lineString,
																	functionNameString,
																	messageString] autorelease];
	} else
		logString = [[[NSString alloc] initWithString:messageString] autorelease];
	
	if(USE_NSLOG)
		NSLog(@"%@", logString);
	else
		printf("%s\n", [logString UTF8String]);
}

- (void)blankLine
{
	if(USE_NSLOG)
		NSLog(@"\n");
	else
		printf("\n");
}

@end


