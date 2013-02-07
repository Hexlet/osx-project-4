//
//  AppDelegate.h
//  iDNA
//
//  Created by Alexander on 23.12.12.
//  Copyright (c) 2012 Alexander. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Cell;

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSButton       *startButton;
    IBOutlet NSButton       *pauseButton;
    IBOutlet NSButton       *loadButton;
    
    IBOutlet NSTextField    *sizePopulationTextField;
    IBOutlet NSTextField    *lengthDNATextField;
    IBOutlet NSTextField    *ratePercentTextField;
    
    
    IBOutlet NSSlider       *sizePopulationSlider;
    IBOutlet NSSlider       *lengthDNASlider;
    IBOutlet NSSlider       *ratePercentSlider;
    
    IBOutlet NSTextView     *goalTextView;
    NSMutableArray          *population;
    
    Cell                    *goalCell;
    
    BOOL                    isPause;
    
    IBOutlet NSTextFieldCell    *generationLabel;
    IBOutlet NSTextFieldCell    *bestIndividualLabel;
    
    NSInteger               *countGenetarion;
}

@property (nonatomic, assign) NSInteger sizePopulation;
@property (nonatomic, assign) NSInteger lengthDNA;
@property (nonatomic, assign) NSInteger ratePercent;

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) NSArray *goalArray;
@property (nonatomic, strong) IBOutlet NSProgressIndicator *progerssBar;

-(IBAction)onStartButton:(id)sender;
-(IBAction)onPauseButton:(id)sender;
-(IBAction)onLoadButton:(id)sender;

-(NSInteger)getRatePercent;
-(NSInteger)getLengthDNA;
-(NSInteger)getSizePopulation;

@end
