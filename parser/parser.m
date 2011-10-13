//
//  parser.m
//  test
//
//  Created by Němec Jaroslav on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "parser.h"


@implementation parser

-(NSMutableArray*) departuresForStop:(NSInteger) idStop withSign:(NSInteger)idSign {

	// creating URL
	NSString *urlString = [[NSString alloc] initWithFormat:@"http://odjezdy.aspone.cz/GetDepartures.ashx?stopId=%d&poleId=%d", idStop, idSign];
	NSURL *url = [NSURL URLWithString:urlString];
	
	// seding HTTP request
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request startSynchronous];
	
	// reading HTTP code
	int statusCode = [request responseStatusCode];
	
	if (statusCode != 200)
	{
		NSLog([request responseStatusMessage]);
		return NULL;
	}
	
	// reading response
	NSString *response = [request responseString];

	
/*	
		EXAMPLE:
		<body>
		<div>
		<div><h3>1146 - Brno, hlavní nádraží</h3></div>
		<div><span>R5</span> Mor. Písek, Kolonie ±<span>8:36</span></div>
		<div><span>S4</span> Náměšť nad Oslavou ±<span>8:39</span></div>
		<div><span>S3</span> Vranovice <span>8:43</span></div>
		<div><span>S41</span> Miroslav žel. st. ±<span>8:49</span></div>
		<div><span>S2</span> Křenovice, horní n. <span>9:10</span></div>
		<a accesskey="*" href="/GetDepartures.ashx?stopId=1146&amp;poleId=98">Obnovit [*]</a>
		<img src="/ga.aspx?utmac=MO-17886138-2&amp;utmn=228302103&amp;utmr=-&amp;utmp=0.000000GetDepartures.ashx0.000000stopId10679601146                0xbffff738oleId-179302745398&amp;guid=ON" alt="ga"/>
		</div>
		</body>
	
	
*/	

	
	// get straight to data 
	NSArray *lines=[response componentsSeparatedByString:@"</h3></div>"]; 
	// lines[0] - dont care
	// lines[1] - interesting data - up to <a accesskey= ....
	if ([lines count] != 2)
	{
		NSLog(@"Error somewhere!\n");
		return NULL;
	}
	
	
	// departures[0] - <div><span>2</span> Modřice, smyčka <span>12:45</span></div>
	// departures[1] - dont care
	NSArray *departures = [[lines objectAtIndex:(NSInteger)1] componentsSeparatedByString:@"<a"];
	if ([departures count] != 2)
	{
		NSLog(@"Error somewhere!\n");
		return NULL;
	}
	
	NSArray *cleanData = [[departures objectAtIndex:(NSInteger)0] componentsSeparatedByString:@"<div><span>"];
	
	
	NSMutableArray *result = [[NSMutableArray alloc]init];
	
	for(NSUInteger i = 1; i < [cleanData count]; i++)
	{
		NSString * singleLine = [cleanData objectAtIndex:i];
		NSArray * lineProperties = [singleLine componentsSeparatedByString:@"span>"];
		// lineProperties[0] - line number
		// lineProperties[1] - end station or direction (sometime includes +-)
		// lineProperties[2] - departure time 
		NSString *lineNumber = [[lineProperties objectAtIndex:0] stringByReplacingOccurrencesOfString:@"</" withString:@""];
		// test VALUE!
		NSUInteger sign;
		NSString * endStation = [[lineProperties objectAtIndex:1] stringByReplacingOccurrencesOfString:@"<" withString:@""]; 
		if ([endStation rangeOfString:@"±"].location == NSNotFound) sign = 0;
		else {
			sign = 1;
			endStation = [endStation stringByReplacingOccurrencesOfString:@"±" withString:@""];
		}		
		
		// test NAME!
		// departure time ...
		NSString *departureTime = [[lineProperties objectAtIndex:2] stringByReplacingOccurrencesOfString:@"</" withString:@""]; 
		departureTime = [departureTime stringByAppendingString:@":00 +0200"];
		NSDate *date = [NSDate date];
		NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
		[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		[dateFormatter setDateFormat:@"yyyy-MM-d"];
		NSString *dateString = [dateFormatter stringFromDate:date];
		dateString = [[dateString stringByAppendingString:@" "] stringByAppendingString: departureTime];
		
		NSDate *depTime = [[NSDate alloc] initWithString:dateString];
		// finally ...
		// lineNumber, sign, endStation, depTime
		NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
		[dict setValue:lineNumber forKey:@"lineNumber" ];
		[dict setValue:depTime forKey:@"depTime"];
		[dict setValue:endStation forKey:@"endStation"];
		[dict setValue:[NSNumber numberWithInteger:sign] forKey:@"sign"];
			
		// add these to array
		[result addObject:dict];
				
		// free memory 
		[dict release];
	}
	return result;
}
@end
