//
//  AppDelegate.m
//  iDNA
//
//  Created by Alexander on 23.12.12.
//  Copyright (c) 2012 Alexander. All rights reserved.
//

#import "AppDelegate.h"
#import "Cell.h"

@implementation AppDelegate

@synthesize ratePercent;
@synthesize lengthDNA;
@synthesize sizePopulation;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - lifeCircle
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    self.ratePercent = [[NSUserDefaults standardUserDefaults]integerForKey:@"ratePercent"]?[[NSUserDefaults standardUserDefaults]integerForKey:@"ratePercent"]:60;
    self.lengthDNA = [[NSUserDefaults standardUserDefaults]integerForKey:@"lengthDNA"]?[[NSUserDefaults standardUserDefaults]integerForKey:@"lengthDNA"]:42;
    self.sizePopulation = [[NSUserDefaults standardUserDefaults]integerForKey:@"sizePopulation"]?[[NSUserDefaults standardUserDefaults]integerForKey:@"sizePopulation"]:3200;
    
    [self addObserver:self forKeyPath:@"lengthDNA" options:0 context:nil];
    [self addObserver:self forKeyPath:@"sizePopulation" options:0 context:nil];
    
    population = [[NSMutableArray alloc]init];
    
    countGenetarion = 0;
    
//    Cell *cell = [[Cell alloc]initWithLength:(int)self.lengthDNA];
//    Cell *cell2 = [[Cell alloc]initWithLength:(int)self.lengthDNA];
//    
//    int hammFirst = [cell hammingDistance:cell2];
//    
//    NSLog(@"%i",hammFirst);
//    
//    [cell mutator:(int)self.ratePercent];
//    [cell2 mutator:(int)self.ratePercent];
//    
//    
//    int hammSecond = [cell hammingDistance:cell2];
//    NSLog(@"%i",hammSecond);
    
    [self getNewGoalPopulation];
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    [[NSUserDefaults standardUserDefaults]setInteger:self.ratePercent forKey:@"ratePercent"];
    [[NSUserDefaults standardUserDefaults]setInteger:self.lengthDNA forKey:@"lengthDNA"];
    [[NSUserDefaults standardUserDefaults]setInteger:self.sizePopulation forKey:@"sizePopulation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    return YES;
}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    NSAlert *closeAlert = [NSAlert alertWithMessageText:NSLocalizedString(@"CLOSE_MESSAGE_TITLE", "Close app")
                                          defaultButton:NSLocalizedString(@"YES", "Yes")
                                        alternateButton:NSLocalizedString(@"CANCEL", "Cancel")
                                            otherButton:nil
                              informativeTextWithFormat:@""];
    
    NSInteger result = [closeAlert runModal];
    if (result == NSAlertAlternateReturn)
        return NSTerminateCancel;
    
    return NSTerminateNow;
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)getNewGoalPopulation
{
    goalCell = [[Cell alloc]initWithLength:(int)self.lengthDNA];
    self.goalArray = goalCell.DNA;
    NSMutableString *goalString = [[NSMutableString alloc]init];
    for (NSString *chr in self.goalArray){
        [goalString appendString:chr];
    }
    [goalTextView setString:goalString];
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Get And Set Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSInteger)getRatePercent
{
    return self.ratePercent;
}

-(NSInteger)getLengthDNA
{
    return self.lengthDNA;
}

-(NSInteger)getSizePopulation
{
    return self.sizePopulation;
}

//-(void)setLengthDNA:(NSInteger)lengthDNA
//{
//    [self getNewGoalPopulation];
//}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Buttons
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(IBAction)onStartButton:(id)sender
{
    [sizePopulationTextField setEnabled:NO];
    [sizePopulationSlider setEnabled:NO];
    [lengthDNATextField setEnabled:NO];
    [lengthDNASlider setEnabled:NO];
    [ratePercentTextField setEnabled:NO];
    [ratePercentSlider setEnabled:NO];
    [startButton setEnabled:NO];
    [pauseButton setEnabled:YES];
    [loadButton setEnabled:NO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (!isPause) {
            @autoreleasepool {
                [self createPopulation:self.sizePopulation];
                [self sortPopulation];
                [self screshivaniePopulation];
                [self mutationPopulation];
                NSInteger maxLength = (100-[[population objectAtIndex:0]hammingDistance:goalCell]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    /* Код, который выполниться в главном потоке */
                    [generationLabel setStringValue:[NSString stringWithFormat:@"%@: %i",NSLocalizedString(@"GENERATION", "Gener"),(int)countGenetarion]];
                    [bestIndividualLabel setStringValue:[NSString stringWithFormat:@"%@ - %i%%",NSLocalizedString(@"BEST_INDIVIDUAL", "best indv"),(int)maxLength]];
                    [_progerssBar setDoubleValue:(double)maxLength];
                });
                countGenetarion++;
            }

        }
        isPause = NO;
        NSLog(@"Pause");
    });
    
}

-(IBAction)onPauseButton:(id)sender
{
    isPause = YES;
    [sizePopulationTextField setEnabled:YES];
    [sizePopulationSlider setEnabled:YES];
    [lengthDNATextField setEnabled:YES];
    [lengthDNASlider setEnabled:YES];
    [ratePercentTextField setEnabled:YES];
    [ratePercentSlider setEnabled:YES];
    [startButton setEnabled:YES];
    [pauseButton setEnabled:NO];
    [loadButton setEnabled:YES];
}

-(IBAction)onLoadButton:(id)sender
{
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Observer
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"lengthDNA"]){
        [self getNewGoalPopulation];
    }
    if ([keyPath isEqualToString:@"sizePopulation"]){
        [self createPopulation:self.sizePopulation];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Population Methods
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)createPopulation:(NSInteger)sizePopul
{
    [population removeAllObjects];
    for (int i=0; i<sizePopul; i++) {
        @autoreleasepool {
            Cell *newCell = [[Cell alloc]initWithLength:(int)self.lengthDNA];
            [population addObject:newCell];
        }
    }
}

-(void)sortPopulation
{
    [population sortUsingComparator:^NSComparisonResult(Cell *obj1, Cell *obj2) {
        if ([obj1 hammingDistance:goalCell] > [obj2 hammingDistance:goalCell]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 hammingDistance:goalCell] < [obj2 hammingDistance:goalCell]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
}

-(void)screshivaniePopulation
{
    int firstInt,secoundInt;
    for (int i=(population.count/2); i<population.count; i++) {
        firstInt = arc4random()%(population.count/2);
        secoundInt = arc4random()%(population.count/2);
        [population removeObjectAtIndex:i];
        [population insertObject:[self combinashionFirst:[population objectAtIndex:firstInt] andSecound:[population objectAtIndex:secoundInt]] atIndex:i];
    }
    
}

-(Cell*)combinashionFirst:(Cell*)first andSecound:(Cell*)secound
{
    int method = arc4random()%3;
    Cell *newCell = [[Cell alloc]initWithLength:(int)self.lengthDNA];
    NSMutableArray *newDNA = [[NSMutableArray alloc]init];
    if (method == 0) {
        for (int i = 0;i<first.DNA.count;i++){
            [newDNA addObject:i<(first.DNA.count/2)?[first.DNA objectAtIndex:i]:[secound.DNA objectAtIndex:i]];
        }
    }
    if (method == 1) {
        for (int i = 0;i<first.DNA.count;i++){
            [newDNA addObject:(i%2)>0?[first.DNA objectAtIndex:i]:[secound.DNA objectAtIndex:i]];
        }
    }
    if (method == 2) {
        for (int i = 0;i<first.DNA.count;i++){
            [newDNA addObject:(i<(first.DNA.count/5) || i>((first.DNA.count/5)*4))?[first.DNA objectAtIndex:i]:[secound.DNA objectAtIndex:i]];
        }
    }
    
    newCell.DNA = newDNA;
    return newCell;
}

-(void)mutationPopulation
{
    for (Cell *cellMutation in population) {
        [cellMutation mutator:(int)self.ratePercent];
    }
}

@end
