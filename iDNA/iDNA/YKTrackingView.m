//
//  YKTrackingView.m
//  iDNA
//
//  Created by Yuri Kirghisov on 22.01.13.
//  Copyright (c) 2013 Yuri Kirghisov. All rights reserved.
//

#import "YKTrackingView.h"

@implementation YKTrackingView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void)awakeFromNib
{
    [[self window] setAcceptsMouseMovedEvents:YES];
    [[self window] makeFirstResponder:self];
}

#pragma mark -
#pragma mark Events Handling

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)mouseExited:(NSEvent *)theEvent
{
    NSLog (@"Mouse Exited");
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    NSLog (@"Mouse Moved");
}
/*
- (void)mouseDown:(NSEvent *)theEvent
{
    NSLog (@"Mouse Down");
}
*/
@end
