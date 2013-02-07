//
//  AppDelegate.h
//  iDNA
//
//  Created by n on 25.12.12.
//  Copyright (c) 2012 witzawitz. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Cell.h"
#import "Graph.h"
#import "Evolution.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
	NSInteger populationSize;
	NSInteger dnaLength;
	NSInteger mutationRate;
	
	Evolution *evolution;
}

@property (assign) IBOutlet NSWindow *window;

// Text fields.
@property (weak) IBOutlet NSTextField *tfPopulationSize;
@property (weak) IBOutlet NSTextField *tfDnaLength;
@property (weak) IBOutlet NSTextField *tfMutationRate;
@property (weak) IBOutlet NSTextField *tfGoalDNA;
// Sliders.
@property (weak) IBOutlet NSSlider *slPopulationSize;
@property (weak) IBOutlet NSSlider *slDnaLength;
@property (weak) IBOutlet NSSlider *slMutationRate;
// Buttons.
@property (weak) IBOutlet NSButton *btStartEvolution;
@property (weak) IBOutlet NSButton *btPause;
@property (weak) IBOutlet NSButton *btLoadGoalDNA;
// Labels.
@property (weak) IBOutlet NSTextField *lbGeneration;
@property (weak) IBOutlet NSTextField *lbBestMatch;

// View for drawing graph.
@property (weak) IBOutlet Graph *vwGraph;

- (IBAction)startEvolution:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)loadGoalDNA:(id)sender;

@end
