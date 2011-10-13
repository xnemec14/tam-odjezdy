#import <Foundation/Foundation.h>

#import "stdio.h"
#import "parser.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	parser *p = [[parser alloc]init];
	
	NSMutableArray *r = [p departuresForStop:(NSInteger)1146 withSign:(NSInteger)1];
	for(NSUInteger i = 0; i < [r count]; i++)
	{
		NSMutableDictionary *x = [r objectAtIndex:i];
		NSLog([x objectForKey:@"lineNumber"]);
		NSLog([x objectForKey:@"endStation"]);
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		[dateFormatter setDateFormat:@"hh:mm:ss dd MMM, yyyy"];
		NSString *dateString = [dateFormatter stringFromDate:[x objectForKey:@"depTime"]];
		NSLog(dateString);
	}
	
	
    [pool drain];
    return 0;
}
