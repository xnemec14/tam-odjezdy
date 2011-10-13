//
//  parser.h
//  test
//
//  Created by Němec Jaroslav on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface parser : NSObject {
	// unused
}
-(NSMutableArray*) departuresForStop:(NSInteger) idStop withSign:(NSInteger) idSign;
@end
