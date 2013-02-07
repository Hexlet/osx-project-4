//
//  AppDelegate.m
//  iDNA
//
//  Created by n on 25.12.12.
//  Copyright (c) 2012 witzawitz. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
{
	NSInteger maxPopulationSize;
	NSInteger maxDnaLength;
	NSInteger maxMutationRate;
}

- (id) init
{
	if (self = [super init])
	{
		maxDnaLength = 100;
		maxMutationRate = 100;
		maxPopulationSize = 10000;
		
		dnaLength = maxDnaLength / 2;
		mutationRate = maxMutationRate / 2;
		populationSize = maxPopulationSize / 2;
	}
	
	return self;
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[_slDnaLength setIntegerValue:dnaLength];
	[_slMutationRate setIntegerValue:mutationRate];
	[_slPopulationSize setIntegerValue:populationSize];
	
	evolution = [[Evolution alloc] init];
	[self setGoalDNA];
	[self addObserver:self forKeyPath:@"dnaLength" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"mutationRate" options:NSKeyValueObservingOptionNew context:nil];
	[self addObserver:self forKeyPath:@"populationSize" options:NSKeyValueObservingOptionNew context:nil];
	
	[_vwGraph setHidden:YES];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	// If any of parameters was changed we should reset evolution.
	[evolution reset];
	[self setLabelForGeneration:0];
	[self setLabelForBestMatch:0];
	
	[_vwGraph reset];
	[_vwGraph setNeedsDisplay:YES];
}	

// Only for remove observers.
-(void) dealloc
{
	[self removeObserver:self forKeyPath:@"dnaLength"];
	[self removeObserver:self forKeyPath:@"mutationRate"];
	[self removeObserver:self forKeyPath:@"populationSize"];
}

- (IBAction)startEvolution:(id)sender
{
	[self checkInputValues];
	if (dnaLength > 0 && populationSize > 0)
	{
		dispatch_queue_t back = dispatch_queue_create("back", NULL);
		dispatch_async(back, ^{
			[self setInputsEnabled:NO];
			
			if ([evolution state] == INIT)
				[evolution initWithMutationRate:mutationRate PopulationSize:populationSize DnaLength:dnaLength];
			else if ([evolution state] == PAUSED)
				[evolution setState:STARTED];
			
			while ([evolution state] == STARTED)
			{
				[evolution perfomStep];
				dispatch_sync(dispatch_get_main_queue(), ^{
					[self updateLabels];
				});
			}
			[self setInputsEnabled:YES];
		});
	}
	else
	{
		NSAlert *alert = [NSAlert alertWithMessageText:@"Какой-то из параметров равен 0." defaultButton:@"Просто закройся" alternateButton:@"Я понял" otherButton:@"Другая кнопка" informativeTextWithFormat:@"Скорее всего это размер ДНК или популяции."];
		[alert runModal];
	}
}

-(void) checkInputValues
{
	[self setDnaLength:[_tfDnaLength integerValue]];
	[self setMutationRate:[_tfMutationRate integerValue]];
	// It can be over 1000 which implies a space after thousands.
	//[self setPopulationSize:[[[_tfPopulationSize stringValue] stringByReplacingOccurrencesOfString:@"\t" withString:@""] integerValue]];
	[self setPopulationSize:[[[[_tfPopulationSize stringValue] componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""] integerValue]];
}

// Pause button pressed.
- (IBAction)pause:(id)sender
{
	[evolution setState:PAUSED];
}

- (IBAction)loadGoalDNA:(id)sender
{
	[self openDNADialog];
}

-(void) openDNADialog
{
	NSOpenPanel *open = [NSOpenPanel openPanel];
	[open setCanChooseFiles:YES];
	[open setAllowsMultipleSelection:NO];
	[open setAllowedFileTypes:[NSArray arrayWithObjects:@"txt", nil]];
	
	if ([open runModal] == NSOKButton)
	{
		@try
		{
			NSString *path = [[[open URLs] objectAtIndex:0] path];
			if (path)
			{
				NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
				// Validate string. Force reading only necessary symbols.
				content = [[content componentsSeparatedByCharactersInSet: [[NSCharacterSet characterSetWithCharactersInString:NUCLEOTIDES] invertedSet]] componentsJoinedByString:@""];
				content = [content substringToIndex:MIN([content length], maxDnaLength)];
				dnaLength = [content length];
				[_tfDnaLength setStringValue:[NSString stringWithFormat:@"%ld", dnaLength]];
				[_tfGoalDNA setStringValue:content];
				[evolution setGoalDNAwithString:@"content"];
			}
		}
		@catch(NSException *exception)
		{
			NSAlert *alert = [NSAlert alertWithMessageText:@"Неправильный файл." defaultButton:@"Просто закройся" alternateButton:@"Я понял" otherButton:@"Другая кнопка" informativeTextWithFormat:@"Что-то пошло не так."];
			[alert runModal];
		}
	}
}

// Set information for labels 'current generation' and 'best match'.
-(void) updateLabels
{
	[self setLabelForGeneration:[evolution step]];
	[self setLabelForBestMatch:[evolution bestMatch]];
}

-(void) setLabelForGeneration: (NSInteger) step
{
	[_lbGeneration setStringValue:[NSString stringWithFormat:@"%ld", step]];
}

-(void) setLabelForBestMatch: (NSInteger) bestMatch
{
	[_lbBestMatch setStringValue:[NSString stringWithFormat:@"%ld", bestMatch]];
}

// Enabling or disabling inputs.
- (void) setInputsEnabled: (Boolean) status
{
	[_btLoadGoalDNA setEnabled:status];
	[_btStartEvolution setEnabled:status];
	[_btPause setEnabled:!status];
	
	[_tfDnaLength setEnabled:status];
	[_tfMutationRate setEnabled:status];
	[_tfPopulationSize setEnabled:status];
	
	[_slDnaLength setEnabled:status];
	[_slMutationRate setEnabled:status];
	[_slPopulationSize setEnabled:status];
}

// Create new goal DNA and sets value to corresponding text field.
- (void) setGoalDNA
{
	[_tfGoalDNA setStringValue:[[evolution createGoalDNAWithLength:dnaLength] DNAtoString]];
}

// Getters.
- (NSInteger) dnaLength			{ return dnaLength; }
- (NSInteger) mutationRate		{ return mutationRate; }
- (NSInteger) populationSize	{ return populationSize; }

// Setters.
- (void) setDnaLength: (NSInteger) x
{
	dnaLength = MIN(x, maxDnaLength);
	[_tfDnaLength setStringValue:[NSString stringWithFormat:@"%ld", dnaLength]];
	if ([evolution state] == INIT || [evolution state] == FINISHED)
		[self setGoalDNA];
}

- (void) setMutationRate: (NSInteger) x
{
	mutationRate = MIN(x, maxMutationRate);
	[_tfMutationRate setStringValue:[NSString stringWithFormat:@"%ld", mutationRate]];
}

- (void) setPopulationSize: (NSInteger) x
{
	populationSize = MIN(x, maxPopulationSize);
	[_tfPopulationSize setStringValue:[NSString stringWithFormat:@"%ld", populationSize]];
}

// Close app if window is closed.
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

@end
