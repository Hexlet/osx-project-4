//
//  RandomGenWindowController.m
//  iDNA
//
//  Created by Admin on 06.02.13.
//  Copyright (c) 2013 Kabest. All rights reserved.
//

#import "RandomGenWindowController.h"

NSString *const IDNARandomNumberChanged = @"iDNARandomNumberChangedNotification";
NSString *const IDNARandomNumberReady = @"iDNARandomNumberReadyNotification";
NSString *const IDNARandomNumber = @"iDNARandomNumber";

@interface RandomGenWindowController ()

@end

@implementation RandomGenWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        progress = 0;
        ready = NO;
    }
    
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRandomNumberChange:) name:IDNARandomNumberChanged object:nil];
    [[self progressBar] setDoubleValue:0];
    [[self progressBar] startAnimation:self];
}

-(void)onRandomNumberChange:(NSNotification*)notification {
    NSNumber *rndNumber = [[notification userInfo] objectForKey:IDNARandomNumber];
    progress++;
    [[self progressBar] incrementBy:1];
    [[self progressBar] displayIfNeeded];
    if (!ready && progress >= 100) {
        ready = YES;
        NSDictionary *dict = [NSDictionary dictionaryWithObject:rndNumber forKey:IDNARandomNumber];
        [[NSNotificationCenter defaultCenter] postNotificationName:IDNARandomNumberReady object:nil userInfo:dict];
        [[self progressBar] stopAnimation:self];
        [NSApp stopModal];
    }
}

-(void)sheetDidEnd:(NSWindow*)sheet returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo {
    [sheet orderOut:self];
}

-(IBAction)exitButtonClicked:(id)sender {
    [NSApp stopModal];
}

@end
