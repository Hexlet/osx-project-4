//
//  Document.m
//  iDNA
//
//  Created by Igor Pavlov on 25.12.12.
//  Copyright (c) 2012 Igor Pavlov. All rights reserved.
//

#import "Document.h"
#import "Cell.h"
#import "Cell+mutator.h"
#import "Cell+hybrid.h"


@implementation Document

+ (void) initialize
{
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];

    [defaultValues setObject:[NSNumber numberWithInteger:10000] forKey:@"MaxPopulationSize"];
    [defaultValues setObject:[NSNumber numberWithInteger:1]     forKey:@"MinPopulationSize"];

    [defaultValues setObject:[NSNumber numberWithInteger:256]   forKey:@"MaxDnaLength"];
    [defaultValues setObject:[NSNumber numberWithInteger:1]     forKey:@"MinDnaLength"];

    [defaultValues setObject:[NSNumber numberWithInteger:100]   forKey:@"MaxMutationRate"];
    [defaultValues setObject:[NSNumber numberWithInteger:0]     forKey:@"MinMutationRate"];

    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}


- (id)init
{
    self = [super init];
    if (self)
    {
        self.goalDnaString    = @"";
        [self setValue:[NSNumber numberWithInteger:10]  forKey:@"populationSize"];
        [self setValue:[NSNumber numberWithInteger:42]  forKey:@"dnaLength"];
        [self setValue:[NSNumber numberWithInteger:1]   forKey:@"mutationRate"];
        self.generationRound  = 0;
        self.bestDnaMatch     = 0;
        self.evolutionStarted = NO;
        self.breakEvolution   = NO;
    }
    return self;
}


- (NSString *)windowNibName
{
    return @"Document";
}


- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}


+ (BOOL) autosavesInPlace
{
    return YES;
}


- (NSData*) dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSMutableData   *data     = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];

    [archiver encodeObject:_goalDna          forKey:@"goalDna"];

    [archiver encodeInteger:_dnaLength       forKey:@"dnaLength"];
    [archiver encodeInteger:_populationSize  forKey:@"populationSize"];
    [archiver encodeInteger:_mutationRate    forKey:@"mutationRate"];

    [archiver encodeInteger:_generationRound forKey:@"generationRound"];
    [archiver encodeDouble:_bestDnaMatch     forKey:@"bestDnaMatch"];

    [archiver finishEncoding];

    return data;
}


- (BOOL) readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    @try
    {
        [self willChangeValueForKey:@"goalDna"];

        [self willChangeValueForKey:@"dnaLength"];
        [self willChangeValueForKey:@"populationSize"];
        [self willChangeValueForKey:@"mutationRate"];

        [self willChangeValueForKey:@"generationRound"];
        [self willChangeValueForKey:@"bestDnaMatch"];

        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];

        _goalDna        = [unarchiver decodeObjectForKey:@"goalDna"];
        
        _dnaLength      = [unarchiver decodeIntegerForKey:@"dnaLength"];
        _populationSize = [unarchiver decodeIntegerForKey:@"populationSize"];
        _mutationRate   = [unarchiver decodeIntegerForKey:@"mutationRate"];

        _generationRound = [unarchiver decodeIntegerForKey:@"generationRound"];
        _bestDnaMatch    = [unarchiver decodeDoubleForKey:@"bestDnaMatch"];

        [unarchiver finishDecoding];

        [self didChangeValueForKey:@"goalDna"];

        [self didChangeValueForKey:@"dnaLength"];
        [self didChangeValueForKey:@"populationSize"];
        [self didChangeValueForKey:@"mutationRate"];

        [self didChangeValueForKey:@"generationRound"];
        [self didChangeValueForKey:@"bestDnaMatch"];

        if (_goalDna)
            self.goalDnaString = [_goalDna description];
    }
    @catch (NSException *exception)
    {
        if (outError)
        {
            NSDictionary *d = [NSDictionary dictionaryWithObject:@"The file is invalid" forKey:NSLocalizedFailureReasonErrorKey];
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:d];
        }
        return NO;
    }

    return YES;
}


- (void) setDnaLength:(NSInteger)dl
{
    _dnaLength = dl;
    self.goalDna = [[Cell alloc] initWithSize:_dnaLength];
}


- (NSInteger) dnaLength
{
    return _dnaLength;
}


- (void) setGoalDna:(Cell*)cell
{
    _goalDna = cell;
    if (_goalDna)
        self.goalDnaString = [_goalDna description];
}


- (IBAction) onStartEvolution:(id)sender
{
    self.randomizationProgress = 0;
    self.prepareEvolution      = YES;

    NSAlert *a = [NSAlert alertWithMessageText:nil
                                 defaultButton:nil
                               alternateButton:nil
                                   otherButton:nil
                     informativeTextWithFormat:NSLocalizedString(@"RANDOMIZE", @"Randomize")];
    [a runModal];

    self.evolutionStarted = YES;
    self.breakEvolution   = NO;

    [self performSelectorInBackground:@selector(evolutionMainMethod:) withObject:nil];
}


- (IBAction) onPause:(id)sender
{
    self.breakEvolution = YES;
}


- (IBAction) onLoadGoalDna:(id)sender
{
    NSOpenPanel *openDlg = [NSOpenPanel openPanel];

    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setCanCreateDirectories:NO];
    [openDlg setPrompt:@"Select DNA goal file"];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setAllowedFileTypes:@[@"txt", @"dna"]];

    if (NSOKButton != [openDlg runModal])
        return;

    NSString *dnaStr = [NSString stringWithContentsOfURL:[openDlg URL] encoding:NSASCIIStringEncoding error:nil];
    if (!dnaStr)
        return;

    const NSInteger maxDnaLength = [[NSUserDefaults standardUserDefaults] integerForKey:@"MaxDnaLength"];
    if ([dnaStr length] > maxDnaLength)
        return;

    Cell *newGoalDna = [[Cell alloc] initWithDnaString:dnaStr];
    if (!newGoalDna)
        return;

    self.dnaLength = [[newGoalDna description] length];
    self.goalDna   = newGoalDna;
}


- (void) evolutionMainMethod:(id)arg
{
    self.generationRound = 0;

    NSPoint prevMouseLoc = [NSEvent mouseLocation];

    NSMutableArray *population = nil;

    while (!self.breakEvolution)
    {
        if (self.prepareEvolution)
        {
            NSPoint const currMouseLoc = [NSEvent mouseLocation];
            float const dx = currMouseLoc.x - prevMouseLoc.x;
            float const dy = currMouseLoc.y - prevMouseLoc.y;

            prevMouseLoc = currMouseLoc;

            float const delta = hypotf(dx, dy);
            self.randomizationProgress += delta;

            if (dx != 0)
                arc4random_addrandom((unsigned char*)&dx, sizeof(dx));
            if (dy != 0)
                arc4random_addrandom((unsigned char*)&dy, sizeof(dy));

            if (self.randomizationProgress > 1000)
            {
                self.prepareEvolution      = NO;
                self.randomizationProgress = 0;

                population = [NSMutableArray arrayWithCapacity:self.populationSize];
                if (!population)
                    break;

                for (NSInteger i = 0; i != self.populationSize; ++i)
                {
                    Cell *newDna = [[Cell alloc] initWithSize:self.dnaLength];
                    [population addObject:newDna];
                }
            }
            else
            {
                [NSThread sleepForTimeInterval:0.1];
            }
        }
        else
        {
            [population sortUsingComparator:^ NSComparisonResult(Cell *lhs, Cell *rhs)
                                            {
                                                const NSInteger ld = [lhs hammingDistance:_goalDna];
                                                const NSInteger rd = [rhs hammingDistance:_goalDna];

                                                if (ld < rd)
                                                    return NSOrderedAscending;

                                                if (ld > rd)
                                                    return NSOrderedDescending;

                                                return NSOrderedSame;
                                            }
            ];

            const NSUInteger minDistance = [[population objectAtIndex:0] hammingDistance:_goalDna];
            self.bestDnaMatch = 1.0 - (double)minDistance/_dnaLength;
            if (0 == minDistance)
                break;

            const NSUInteger hybridizationStartIndex = self.populationSize/2;
            for (NSUInteger i = hybridizationStartIndex; i != self.populationSize; ++i)
            {
                const NSUInteger i1 = hybridizationStartIndex > 0 ? arc4random_uniform((u_int32_t)hybridizationStartIndex) : 0;
                const NSUInteger i2 = hybridizationStartIndex > 0 ? arc4random_uniform((u_int32_t)hybridizationStartIndex) : 0;
                Cell *a = [population objectAtIndex:i1];
                Cell *b = [population objectAtIndex:i2];
                Cell *hybrid = [Cell makeHybridWith:a andWith:b];
                [population replaceObjectAtIndex:i withObject:hybrid];
            }

            const NSUInteger mRate = _mutationRate;
            for (Cell *c in population)
                [c mutate:mRate];

            ++self.generationRound;
        }
    }

    self.evolutionStarted = NO;
}


@end
