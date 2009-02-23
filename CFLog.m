/* 
 * CFLog is a singleton logging object for more powerful logging in your cocoa projects
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
 * CFLog.m
 * 
 * Created by Camron Flanders on 2.23.09
 * Copyright 2009 camronflanders. All rights reserved.
 * 
 */

#import "CFLog.h"


@implementation CFLog

#pragma mark -
#pragma mark SINGLETON STUFF

static CFLog *sharedDebug = nil;
static NSArray *severityLevels = nil;
static NSString *logFormatString = @"[%@] File:%@ Line:%d\n                                            %@\n\n";

+ (CFLog *) sharedDebug
{
	@synchronized(self)
	{
		if (sharedDebug == nil)
			[[self alloc] init];
	}
	return sharedDebug;
}

+ (void)initialize
{
	if(severityLevels == nil)
		severityLevels = [[NSArray alloc] initWithObjects: @"", 
						   @"CRITICAL", 
						   @" ERROR  ", 
						   @"WARNING ", 
						   @"  INFO  ", 
						   @" DEBUG  ", nil];	
}

+ (id) allocWithZone:(NSZone *) zone
{
	@synchronized(self)
	{
		if (sharedDebug == nil)
		{
			sharedDebug = [super allocWithZone:zone];
			return sharedDebug;
		}
	}
	return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
	return self;
}

- (id)retain
{
	return self;
}

- (void)release
{
	// No action required...
}

- (unsigned)retainCount
{
	return UINT_MAX;
}

- (id)autorelease
{
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark -
#pragma mark debug methods
- (void)log:(int)severity overrideGlobal:(BOOL)override fileName:(char *)file lineNumber:(int)line input:(NSString *)message, ...
{
	// check to see if we have disabled debugging globally and return unless
	// we want to override the global setting for this statment.
	if(!GLOBAL_SOFT_ENABLE && !override) return;
	if(severity > LOG_LEVEL) return;	// if we are below our threshold, return
	
	va_list argList;
	va_start(argList, message);
	NSString *messageStr = [[NSString alloc] initWithFormat:message 
												  arguments:argList];
	va_end(argList);
	
	// use regular NSLog output and get out of town.
	if(BARE_OUTPUT)
	{
		NSLog(messageStr);
		return;
	}
	
	// make sure we have a valid severity level.
	int outputLevel;
	if(severity == 0)
		outputLevel = 1;
	else if(!severity)
		outputLevel = DEFAULT_SEVERITY;
	else
		outputLevel = severity;

	NSString *outputLevelString = [NSString stringWithString:[severityLevels objectAtIndex:outputLevel]];
	
	NSString *filePath = [[[NSString alloc] initWithBytes:file 
												   length:strlen(file) 
												 encoding:NSUTF8StringEncoding] autorelease];	
	if(!LOG_FULL_PATH)
		filePath = [filePath lastPathComponent];
	
	NSString *logString = [[[NSString alloc] initWithFormat:logFormatString, 
															outputLevelString, 
															filePath, 
															line, 
															messageStr] autorelease];
	
	NSLog(@"%@", logString);
}

@end