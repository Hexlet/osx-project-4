//
//  AppDelegate.h
//  iDNA
//
//  Created by Admin on 23.12.12.
//  Copyright (c) 2012 Kabest. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Cell.h"
#import "PreferencesController.h"
#import "RandomGenWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property NSInteger populationSize;
@property NSInteger dnaLength;
@property NSInteger mutationRate;
@property NSInteger minimumHammingDistance;
@property Cell *goalDNA;
@property BOOL isFirstRun;
@property BOOL isRunning;
@property NSInteger generation;
@property NSInteger bestIndividualMatch;
@property NSMutableArray *population;
@property PreferencesController *preferences;
@property RandomGenWindowController *randomWindow;

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *populationSizeEdit;
@property (weak) IBOutlet NSTextField *dnaLengthEdit;
@property (weak) IBOutlet NSTextField *mutationRateEdit;
@property (weak) IBOutlet NSSlider *populationSizeSlider;
@property (weak) IBOutlet NSSlider *dnaLengthSlider;
@property (weak) IBOutlet NSSlider *mutationRateSlider;
@property (weak) IBOutlet NSTextField *generationLabel;
@property (weak) IBOutlet NSTextField *bestMatchLabel;
@property (weak) IBOutlet NSProgressIndicator *mutationProgress;
@property (weak) IBOutlet NSTextField *goalDNATextField;

-(IBAction)startEvolutionButtonClicked:(id)sender;
-(IBAction)pauseEvolutionButtonClicked:(id)sender;
-(IBAction)saveGoalDNAButtonClicked:(id)sender;
-(IBAction)loadGoalDNAButtonClicked:(id)sender;

-(void)initEvolution;
-(void)startEvolution;

@end
