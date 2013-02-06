//
//  RandomWindowController.m
//  iDNA
//
//  Created by alex on 05/02/2013.
//  Copyright (c) 2013 alex. All rights reserved.
//

#import "RandomWindowController.h"

@implementation RandomWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        //
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRandomChange:) name:@"RandomGeneration" object:nil];
}

- (IBAction)onExit:(id)sender
{
    [NSApp stopModal];
}

-(void)handleRandomChange:(NSNotification *)notification
{
    NSNumber *number = [[notification userInfo] objectForKey: @"random"];
    [[self progressBar] incrementBy:1];
    
    [_random initWithLong:[_random integerValue] + [number integerValue]];
    
    if ([[self progressBar] doubleValue] >= 100) {
        [NSApp stopModal];
    }
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
    
    NSDictionary *d = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:_random] forKey:@"random"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FinishRandomGeneration" object:self userInfo:d];
}


@end
