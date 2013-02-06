//
//  MouseView.m
//  iDNA
//
//  Created by alex on 05/02/2013.
//  Copyright (c) 2013 alex. All rights reserved.
//

#import "MouseView.h"

@implementation MouseView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        p = NSMakePoint(0, 0);
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor blackColor] set];
    [NSBezierPath strokeRect:[self bounds]];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    NSPoint realPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    int rand = (realPoint.x - p.x)*(realPoint.y - p.y);
    p = NSMakePoint(realPoint.x, realPoint.y);
    
    NSDictionary *d = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:rand] forKey:@"random"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RandomGeneration" object:self userInfo:d];
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

-(void)viewDidMoveToWindow
{
    NSTrackingArea *trackingArea = [[NSTrackingArea alloc]
                                    initWithRect:[self frame]
                                                        options:NSTrackingMouseMoved+NSTrackingActiveInKeyWindow
                                                        owner:self
                                                        userInfo:nil];
    [self addTrackingArea:trackingArea];
    [self becomeFirstResponder];
    
}

@end
