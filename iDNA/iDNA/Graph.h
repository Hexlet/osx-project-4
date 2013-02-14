//
//  Graph.h
//  iDNA
//
//  Created by n on 11.01.13.
//  Copyright (c) 2013 witzawitz. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Graph : NSView
{
	NSPointArray points;
	NSMutableData *pointData;
	float width;
	float height;
	float originX;
}

-(void) addPointWithY: (float) y;
-(void) reset;

@end
