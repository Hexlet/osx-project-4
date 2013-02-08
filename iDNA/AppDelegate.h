//
//  AppDelegate.h
//  iDNA
//
//  Created by Роман Евсеев on 25.12.12.
//  Copyright (c) 2012 Роман Евсеев. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Population.h"
@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSTextField *textPopulationSize;
@property (weak) IBOutlet NSTextField *textDNALength;
@property (weak) IBOutlet NSTextField *textMutationRate;
@property (weak) IBOutlet NSTextField *textGoalDNA;
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSButton *btnStartEvolution;
@property (weak) IBOutlet NSButton *btnPause;
@property (weak) IBOutlet NSButton *btnLoadGoalDNA;
@property (weak) IBOutlet NSTextField *lblGeneration;
@property (weak) IBOutlet NSTextField *lblBestMatch;
@property (weak) IBOutlet NSSliderCell *sliderDNALength;
@property (weak) IBOutlet NSSlider *sliderPopulationSize;
@property (weak) IBOutlet NSSlider *sliderMutationRate;

@property Population * population;

- (IBAction)startEvolution:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)loadGoalDNA:(id)sender;
- (IBAction)changedDNA:(id)sender;
- (IBAction)changedPopulation:(id)sender;
- (IBAction)changedMutationRate:(id)sender;

- (void) evolution: (id)sender;
@end
