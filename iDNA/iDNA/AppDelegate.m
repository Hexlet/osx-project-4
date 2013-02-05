//
//  AppDelegate.m
//  iDNA
//
//  Created by alex on 17/12/2012.
//  Copyright (c) 2012 alex. All rights reserved.
//

#import "AppDelegate.h"
#import "Cell.h"
#import "Population.h"
#import "PreferencesController.h"
#import "RandomWindowController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setValue:[NSNumber numberWithLong:[preferences populationSize]] forKey:@"populationSize"];
    [self setValue:[NSNumber numberWithLong:[preferences DNALength]] forKey:@"DNALength"];
    [self setValue:[NSNumber numberWithLong:[preferences mutationRate]] forKey:@"mutationRate"];
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"MSG_EXIT", @"") defaultButton:NSLocalizedString(@"BTN_YES", @"")alternateButton:NSLocalizedString(@"BTN_NO", @"") otherButton:nil informativeTextWithFormat:@""];
    
    NSInteger answer = [alert runModal];
    
    if (answer == NSAlertAlternateReturn) return NSTerminateCancel;
    
    return NSTerminateNow;
}

-(id)init {
    if (self = [super init]) {
        preferences = [[PreferencesController alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDNAChange:) name:DNAChangeNotification object:nil];
        
        _DNA = [[Cell alloc] init];
        [self addObserver:self forKeyPath:@"populationSize" options:0 context:nil];
        [self addObserver:self forKeyPath:@"DNALength" options:0 context:nil];
        [self addObserver:self forKeyPath:@"mutationRate" options:0 context:nil];
        
        paused = NO;
    }
    
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"populationSize"]) {
        [preferences setPopulationSize:[[self valueForKey:@"populationSize"] intValue]];
    } else if ([keyPath isEqualToString:@"DNALength"]) {
        [_DNA populateForSize:[[self valueForKey:@"DNALength"] intValue]];
        [preferences setDNALength:[[self valueForKey:@"DNALength"] intValue]];
    } else if ([keyPath isEqualToString:@"mutationRate"]) {
        [preferences setMutationRate:[[self valueForKey:@"mutationRate"] intValue]];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)handleDNAChange:(NSNotification *)n
{
    [_goalDNATextField setStringValue:[_DNA asString]];
}

- (IBAction)startEvolution:(id)sender
{
    randomPanel = [[RandomWindowController alloc] initWithWindowNibName:@"RandomWindowController"];
    
    [NSApp beginSheet: [randomPanel window]
       modalForWindow: [self window]
        modalDelegate: randomPanel
       didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:)
          contextInfo: nil];

    [NSApp runModalForWindow: [randomPanel window]];

    [NSApp endSheet: [randomPanel window]];
    //[[randomPanel window] orderOut: self];
    
    /*
    [self setStateOfUIElements:FALSE];

    [self performSelectorInBackground:@selector(evolutionJob) withObject:nil];
    */
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    NSLog(@"finish");
    
    [sheet orderOut:self];
}

-(void)evolutionJob
{
    Population *population = [[Population alloc] initPopulationWithSize:[[self valueForKey:@"populationSize"] intValue] andSizeDNA:[[self valueForKey:@"DNALength"] intValue] andGoalDNA:_DNA];
    
    int i = 1;
    int evolutionResult = -1;
    int bestMatch = 999;
    int l = [[self valueForKey:@"DNALength"] intValue];
    paused = NO;

    while (true) {
        [_generationLabel setStringValue:[NSString stringWithFormat:@"Generation: %d", i]];
        
        evolutionResult = [population evolution:[[self valueForKey:@"mutationRate"] intValue]];
        if (bestMatch > evolutionResult) {
            bestMatch = evolutionResult;
            [_bestMatchLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"BEST_MATCH", ""), 100-bestMatch*100/l]];
        }
        
        // для отладки
        /*
        [_goalDNATextField setStringValue:[[_DNA asString] stringByAppendingFormat:@"\r\n%@ - %d (%d)", [[population bestMatch] asString], [[population bestMatch] hammingDistance:_DNA], evolutionResult]];
        */
        
        if (paused || !bestMatch) {
            [self setStateOfUIElements:TRUE];
            break;
        }
        
        i++;
    }
}

-(void)setStateOfUIElements:(BOOL)newState
{
    [_pauseButton setEnabled:!newState];
    [_startEvolutionButton setEnabled:newState];
    [_populationSizeSlider setEnabled:newState];
    [_populationSizeTextField setEnabled:newState];
    [_DNALengthSlider setEnabled:newState];
    [_DNALengthTextField setEnabled:newState];
    [_mutationRateSlider setEnabled:newState];
    [_mutationRateTextField setEnabled:newState];
    [_loadDNAButton setEnabled:newState];
}

- (IBAction)pauseClick:(id)sender
{
    paused = YES;
}

- (IBAction)saveAs:(id)sender
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    if ([panel runModal] == NSOKButton) {
        NSError *error;
        
        [[[self DNA] asString] writeToURL:[panel URL] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        if (error.code) {
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"ERROR_SAVE", @"") defaultButton:NSLocalizedString(@"BTN_CLOSE", @"") alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
            [alert runModal];
        }
    }
}

- (IBAction)openFile:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    if ([panel runModal] == NSOKButton) {
        NSError *error;
        
        NSString *string = [NSString stringWithContentsOfURL:[panel URL] encoding:NSUTF8StringEncoding error:&error];
        // ставим правильное значение длины ДНК
        [self setValue:[NSNumber numberWithInt:(int)string.length] forKey:@"DNALength"];
        // пишем новое ДНК в соотв. поле
        [_DNA populateWithString:string];
        
        if (error.code) {
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"ERROR_OPEN", @"") defaultButton:NSLocalizedString(@"BTN_CLOSE", @"") alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
            [alert runModal];
        }
    }
}

@end
