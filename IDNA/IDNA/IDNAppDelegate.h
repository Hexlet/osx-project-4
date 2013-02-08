//
//  IDNAppDelegate.h
//  IDNA
//
//  Created by Dmitriy Zhukov on 06.01.13.
//  Copyright (c) 2013 Dmitriy Zhukov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IDNRandomGenerator.h"
@class IDNCell;
@class IDNPopulation;

extern NSString *const IDNPopulationSizePref;
extern NSString *const IDNDNALengthPref;
extern NSString *const IDNMutationPref;


@interface IDNAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property NSInteger populationSize;
@property NSInteger DNALength;
@property NSInteger mutationRate;
@property NSInteger generationCount;
@property NSInteger distanceToTargetDNA;
@property NSInteger progress;
@property IDNRandomGenerator* randomGenerator;

@property IDNCell* goalDNA;
@property (weak) IBOutlet NSTextField *goalDNAField;

@property IDNPopulation* workingPopulation;

@property BOOL interfaceStatement;
@property BOOL startStatement;
@property BOOL pauseStatement;
@property BOOL pauseEvolutionFlag;
@property BOOL stopEvolutionFlag;
@property BOOL randomFlag;
@property BOOL openSaveDesible;


- (IBAction)loadDNAfromFile:(id)sender;
- (IBAction)saveData:(id)sender;
- (IBAction)startEvolution:(id)sender;
- (IBAction)pauseEvolution:(id)sender;
- (IBAction)stopEvolution:(id)sender;




@end
