//
//  AppDelegate.m
//  iDNA
//
//  Created by Роман Евсеев on 25.12.12.
//  Copyright (c) 2012 Роман Евсеев. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self loadGoalDNA:self];
}

-(void)evolution:(id)sender {
    while (!self.population.evolution && self.btnPause.isEnabled) {
        [_lblBestMatch setStringValue:
         [NSString stringWithFormat: @"Best match: %li", self.population.bestMatch]];
        [_lblGeneration setStringValue:
         [NSString stringWithFormat: @"Generation: %li", self.population.step]];
    }

    [_lblBestMatch setStringValue:
     [NSString stringWithFormat: @"Best match: %li", self.population.bestMatch]];
    [_lblGeneration setStringValue:
     [NSString stringWithFormat: @"Generation: %li", self.population.step]];
    
    [self pause:self];
}

- (IBAction)startEvolution:(id)sender {
    [_btnPause setEnabled:YES];
    [_btnStartEvolution setEnabled:NO];
    [_btnLoadGoalDNA setEnabled:NO];
    
    [_textPopulationSize setEnabled:NO];
    [_textDNALength setEnabled:NO];
    [_textMutationRate setEnabled:NO];
    [self performSelectorInBackground:@selector(evolution:) withObject:self];
}

- (IBAction)pause:(id)sender {
    [_btnPause setEnabled:NO];
    [_btnStartEvolution setEnabled:YES];
    [_btnLoadGoalDNA setEnabled:YES];
    
    [_textPopulationSize setEnabled:YES];
    [_textDNALength setEnabled:YES];
    [_textMutationRate setEnabled:YES];
}

- (IBAction)loadGoalDNA:(id)sender {
    _population = [[Population alloc] initWithCapacity:[_textPopulationSize integerValue] DNALength:[_textDNALength integerValue]];
    [_textGoalDNA setStringValue:[self.population.goalDNA description]];
    [_lblBestMatch setStringValue:@""];
    [_lblGeneration setStringValue:@""];
}

- (IBAction)changedDNA:(id)sender {
    NSUInteger val = [(NSTextField *)sender integerValue];
    if (val>[_sliderDNALength maxValue]) {
        val = [_sliderDNALength maxValue];
    }
    [_textDNALength setIntegerValue:val];
    [_sliderDNALength setIntegerValue:val];
    [self loadGoalDNA:self];
}

-(void)changedPopulation:(id)sender {
    NSUInteger val = [(NSTextField *)sender integerValue];
    if (val>[_sliderPopulationSize maxValue]) {
        val = [_sliderPopulationSize maxValue];
    }
    [_textPopulationSize setIntegerValue:val];
    [_sliderPopulationSize setIntegerValue:val];
}

-(void)changedMutationRate:(id)sender {
    NSUInteger val = [(NSTextField *)sender integerValue];
    if (val>[_sliderMutationRate maxValue]) {
        val = [_sliderMutationRate maxValue];
    }
    [_textMutationRate setIntegerValue:val];
    [_sliderMutationRate setIntegerValue:val];
}

@end
