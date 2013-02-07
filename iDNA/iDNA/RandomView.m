//
//  RandomView.m
//  iDNA
//
//  Created by Admin on 07.02.13.
//  Copyright (c) 2013 Kabest. All rights reserved.
//

#import "RandomView.h"
#import "RandomGenWindowController.h"

@implementation RandomView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        lastPoint = NSMakePoint(0, 0);
        
        attr = [NSMutableDictionary dictionary];
        [attr setObject:[NSFont userFontOfSize:16.0] forKey:NSFontAttributeName];
        [attr setObject:[NSColor blueColor] forKey:NSForegroundColorAttributeName];
        
        string = NSLocalizedString(@"MOVE_HERE", @"Please move mouse inside this box");
    }
    
    return self;
}

-(void)awakeFromNib {
    [[self window] setAcceptsMouseMovedEvents:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSRect bounds = [self bounds];
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:bounds];    
    
    [self drawText];
}

-(void)drawText {
    NSRect bounds = [self bounds];
    NSSize strSize = [string sizeWithAttributes:attr];
    NSPoint strOrigin;
    strOrigin.x = bounds.origin.x + (bounds.size.width - strSize.width)/2;
    strOrigin.y = bounds.origin.y + (bounds.size.height - strSize.height)/2;
    [string drawAtPoint:strOrigin withAttributes:attr];
}

-(BOOL)isOpaque {
    return YES;
}

-(BOOL)acceptsFirstResponder {
    return YES;
}

-(BOOL)resignFirstResponder {
    return YES;
}

-(BOOL)becomeFirstResponder {
    return YES;
}

-(void)mouseMoved:(NSEvent*)theEvent {
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    if (hypot(abs(lastPoint.x - p.x), abs(lastPoint.y - p.y)) > 20) {
        lastPoint = NSMakePoint(p.x, p.y);
        
        rnd = rnd + (int)p.x*(int)p.y;
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:rnd] forKey:IDNARandomNumber];
        [[NSNotificationCenter defaultCenter] postNotificationName:IDNARandomNumberChanged object:nil userInfo:dict];
    }
}

@end
