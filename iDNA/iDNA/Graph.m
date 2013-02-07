//
//  Graph.m
//  iDNA
//
//  Created by n on 11.01.13.
//  Copyright (c) 2013 witzawitz. All rights reserved.
//

#import "Graph.h"

@implementation Graph

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
		pointData = [[NSMutableData alloc] init];
		width = self.frame.size.width;
		height = self.frame.size.height;
		originX = self.frame.origin.x;
    }
    
    return self;
}

-(void) addPoint: (NSPoint) point
{
	NSUInteger pointCount = [pointData length] / sizeof(NSPoint);
	[pointData setLength:(pointCount+1) * sizeof(NSPoint)];
	points = [pointData mutableBytes];
	points[pointCount] = point;
}

-(void) addPointWithX: (float) x andY: (float) y
{
	[self addPoint:NSMakePoint(x, y)];
}

-(void) addPointWithY: (float) y
{
	NSUInteger pointCount = [pointData length] / sizeof(NSPoint);
	if (pointCount == 0)
		[self addPoint:NSMakePoint(0, y)];
	else
	{
		float lastX = points[pointCount-1].x;
		[self addPoint:NSMakePoint(lastX+1, y)];
	}
}

-(void) reset
{
	[pointData setLength:0];
	points = NULL;
}

- (void)drawRect:(NSRect)rect
{
	[NSBezierPath strokeLineFromPoint:NSMakePoint(0, 0) toPoint:NSMakePoint(0, height)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(0, 0) toPoint:NSMakePoint(width, 0)];
	
	NSUInteger pointCount = [pointData length] / sizeof(NSPoint);
	if (pointCount > 0)
	{
		NSBezierPath *path = [NSBezierPath bezierPath];
		NSUInteger pointCount = [pointData length] / sizeof(NSPoint);
		if (pointCount > width)
		{
			//originX--;
			//[self translateOriginToPoint:NSMakePoint(-points[pointCount-(int)width-1].x, 0)];
		}
		[path appendBezierPathWithPoints:[pointData mutableBytes] count: pointCount];
		[path stroke];
	}
}

@end
