//
//  YKAppDelegate.h
//  iDNA
//
//  Created by Yuri Kirghisov on 12.12.12.
//  Copyright (c) 2012 Yuri Kirghisov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "YKDNA.h"
#import "YKDNAPreferences.h"

@interface YKAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSTextField *populationSizeTextField;
    IBOutlet NSTextField *dnaLengthTextField;
    IBOutlet NSTextField *mutationRateTextField;
    IBOutlet NSTextField *goalDNATextField;

    IBOutlet NSProgressIndicator *evolutionProgressIndicator;
}

@property (assign) IBOutlet NSWindow *window;

@property NSUInteger populationSize;
@property NSUInteger dnaLength;
@property NSUInteger mutationRate;

@property (retain) YKDNA *goalDNA;
@property (retain) NSMutableArray *population;
@property NSUInteger generation;
@property NSUInteger minimumHammingDistance;
@property NSUInteger bestIndividualMatch;

// YES во время выполнения рассчетов, NO во время простоя. Используется для включения и отключения объектов пользвательского интерфейса с помощью привязывания.
@property BOOL isFirstRun;

// YES во время выполнения рассчетов, NO во время простоя. Используется для включения и отключения объектов пользвательского интерфейса с помощью привязывания.
@property BOOL isBusy;

// Индикатор достижения цели, т.е. выхода из цикла просчета.
@property BOOL isGoalReached;

- (IBAction)startEvolutionButtonPressed:(id)sender;
- (IBAction)pauseButtonPressed:(id)sender;
- (IBAction)loadGoalDnaButtonPressed:(id)sender;

@end
