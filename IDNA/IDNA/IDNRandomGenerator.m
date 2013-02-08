//
//  IDNRandomGenerator.m
//  IDNA
//
//  Created by Dmitriy Zhukov on 08.02.13.
//  Copyright (c) 2013 Dmitriy Zhukov. All rights reserved.
//

#import "IDNRandomGenerator.h"

NSString *const IDNRandomNumberNotification = @"IDNRandomNumberNotification";

@interface IDNRandomGenerator ()

@end

@implementation IDNRandomGenerator


-(id)init {
    self = [super initWithWindowNibName:@"IDNRandomGenerator"];
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        self.numberOfMouseMove = 0;
        self.randomNumber = 0;
    }
    
    return self;
}


- (void)windowDidLoad
{
    [super windowDidLoad];
    [[self window] makeFirstResponder: self];
    [[self window] setAcceptsMouseMovedEvents: YES];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- ( void ) mouseMoved :( NSEvent  *) theEvent
{
    if (self.numberOfMouseMove < 200) {
        
        NSPoint locationPoint = [theEvent locationInWindow];
        self.randomNumber = self.randomNumber + ((locationPoint.x+locationPoint.y)/2);
        self.numberOfMouseMove ++;
    } else {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        NSDictionary *d = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.randomNumber] forKey:@"randomNumber"];
        [nc postNotificationName:IDNRandomNumberNotification object:self userInfo:d];
        [[self window] close];
    }
}


@end
