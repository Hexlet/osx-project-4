//
//  IDNAppDelegate.m
//  IDNA
//
//  Created by Dmitriy Zhukov on 06.01.13.
//  Copyright (c) 2013 Dmitriy Zhukov. All rights reserved.
//

#import "IDNAppDelegate.h"
#import "IDNCell.h"
#import "IDNPopulation.h"
#import "IDNRandomGenerator.h"

@implementation IDNAppDelegate

NSString *const IDNPopulationSizePref = @"IDNPopulationSizePref";
NSString *const IDNDNALengthPref = @"IDNDNALengthPref";
NSString *const IDNMutationPref = @"IDNMutationPref";


#pragma mark
#pragma mark - userDefaultmethods

+(void)initialize {
    NSMutableDictionary *defaulValues = [NSMutableDictionary dictionary];
    [defaulValues setObject:[NSNumber numberWithInteger:1000]forKey:IDNPopulationSizePref];
    [defaulValues setObject:[NSNumber numberWithInteger:10] forKey:IDNDNALengthPref];
    [defaulValues setObject:[NSNumber numberWithInteger:10] forKey:IDNMutationPref];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaulValues];
}

+(void)setPreferenceIDNPopulationSize:(NSInteger)value {
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:IDNPopulationSizePref];
}

+(NSInteger)preferenceIDNPopulationSize {
    return [[NSUserDefaults standardUserDefaults] integerForKey:IDNPopulationSizePref];
}

+(void)setPreferenceIDNDNALength:(NSInteger)value {
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:IDNDNALengthPref];
}
+(NSInteger)preferenceIDNDNALength {
    return [[NSUserDefaults standardUserDefaults] integerForKey:IDNDNALengthPref];
}

+(void)setPreferenceIDNMutationRate:(NSInteger)value {
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:IDNMutationPref];
}
+(NSInteger)preferenceIDNMutationRate {
    return [[NSUserDefaults standardUserDefaults] integerForKey:IDNMutationPref];
}


#pragma mark
#pragma mark - init dealloc

-(id)init {
    self = [super init];
    if (self) {
        self.populationSize = [IDNAppDelegate preferenceIDNPopulationSize];
        self.DNALength = [IDNAppDelegate preferenceIDNDNALength];
        self.mutationRate = [IDNAppDelegate preferenceIDNMutationRate];
        self.generationCount=0;
        self.progress=0;
        self.distanceToTargetDNA=0;
        self.interfaceStatement = true;
        self.startStatement = true;
        self.stopEvolutionFlag = true;
        self.pauseEvolutionFlag = true;
        self.pauseStatement = false;
        self.randomFlag = false;
        self.openSaveDesible = true;
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(handleRandomNumberChange:) name:IDNRandomNumberNotification object:nil];
        
    }
    return self;
}

-(void)dealloc {
    [self removeObserver:self forKeyPath:@"populationSize"];
    [self removeObserver:self forKeyPath:@"DNALength"];
    [self removeObserver:self forKeyPath:@"mutationRate"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark
#pragma mark - load params

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.workingPopulation = [[IDNPopulation alloc] init]; //возможно исключить
    self.goalDNA = [[IDNCell alloc]init];
    [self.goalDNA fillDNAArrayWithCapacity:self.DNALength];
    [self.goalDNAField setStringValue:[self.goalDNA.DNA componentsJoinedByString:@""]];  
    
    [self addObserver:self forKeyPath:@"populationSize" options:NSKeyValueObservingOptionOld context:@"populationSizeContext"];
    
    [self addObserver:self forKeyPath:@"DNALength" options:NSKeyValueObservingOptionOld context:@"DNALengthContext"];
    
    [self addObserver:self forKeyPath:@"mutationRate" options:NSKeyValueObservingOptionOld context:@"mutationRateContext"];

    
    
}

#pragma mark
#pragma mark - observe method

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(context == @"populationSizeContext") {
        [IDNAppDelegate setPreferenceIDNPopulationSize:self.populationSize];
    }
    else if(context == @"DNALengthContext") {
        [IDNAppDelegate setPreferenceIDNDNALength:self.DNALength];
        [self.goalDNA fillDNAArrayWithCapacity:self.DNALength];
        [self.goalDNAField setStringValue:[self.goalDNA.DNA componentsJoinedByString:@""]];
    }
    else if(context == @"mutationRateContext") {
        [IDNAppDelegate setPreferenceIDNMutationRate:self.mutationRate];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }


}

#pragma mark
#pragma mark - pause/stop/run

- (IBAction)startEvolution:(id)sender {
    self.interfaceStatement = false;
    self.startStatement = false;
    self.pauseStatement = true;
    self.stopEvolutionFlag = false;
    self.pauseEvolutionFlag = false;
    if ([self.workingPopulation.population count]==0) {
        [self showRandomPanel];
        // [self.workingPopulation createPopulationWithCount:_populationSize andDNALength:_DNALength];
    }
    if (self.randomFlag) {
        [self performSelectorInBackground:@selector(evolution) withObject:nil];}
}

- (IBAction)pauseEvolution:(id)sender {
    self.pauseEvolutionFlag = true;
    self.startStatement = true;
    self.pauseStatement = false;
    
}

- (IBAction)stopEvolution:(id)sender {
    self.stopEvolutionFlag = true;
}



#pragma mark
#pragma mark - upgrade/reset interface

- (void)resetInterface {
    self.stopEvolutionFlag = true;
    self.pauseEvolutionFlag = true;
    self.interfaceStatement = true;
    self.startStatement = true;
    self.pauseStatement = false;
    self.randomFlag = false;
    IDNPopulation *newPopulation = [[IDNPopulation alloc]init];
    self.workingPopulation = newPopulation;
    self.generationCount = 0;
    self.distanceToTargetDNA = 0;
    self.progress = 0;
    
}

- (void)upgradeInterface {
    self.generationCount = self.workingPopulation.generationNumber;
    self.distanceToTargetDNA = self.workingPopulation.bestDNADistanseInPopulation;
    self.progress = self.workingPopulation.progressToTarget;
}

#pragma mark
#pragma mark - Evolution

- (void) evolution {
    for (;;) {
        if (self.pauseEvolutionFlag) {
            break;
        } else if (self.stopEvolutionFlag){
            [self performSelectorOnMainThread:@selector(resetInterface) withObject:nil waitUntilDone:YES];
            break;
        }
        else {
            [self.workingPopulation sortPopulationByHummingDistanceTo:self.goalDNA]; //первый этап
            if (self.workingPopulation.bestDNADistanseInPopulation == 0) {//Если присутствует идеальное днк - прекращаем эволюцию.
                
                [self performSelectorOnMainThread:@selector(upgradeInterface) withObject:nil waitUntilDone:YES];
                [self performSelectorOnMainThread:@selector(modalArlertCall) withObject:nil waitUntilDone:YES]; //Вызываем модальное окно.
                [self performSelectorOnMainThread:@selector(resetInterface) withObject:nil waitUntilDone:YES]; //Сбрасываем интерфейс
                
                break;
            } else {
                
                [self.workingPopulation crossingBestDNA];//Второй этап
                [self.workingPopulation populationMutate: self.mutationRate];//Третий этап
                [self performSelectorOnMainThread:@selector(upgradeInterface) withObject:nil waitUntilDone:YES];
                
            }
        }
    }
}

#pragma mark
#pragma mark - load/save method

#pragma mark
#pragma mark - load/save method

- (IBAction)loadDNAfromFile:(id)sender {
    NSOpenPanel* newOpenPanel = [NSOpenPanel openPanel];
    [newOpenPanel setAllowedFileTypes:[NSArray arrayWithObject:@"txt"]];
    
    [newOpenPanel setAllowsOtherFileTypes:NO];
    NSInteger result = [newOpenPanel runModal];
    
    if (result == NSOKButton)
    {
        //Начало проверки намерений пользователя
        NSInteger check = NSRunAlertPanel (NSLocalizedString(@"OPEN_HEADER_MSG", @""), NSLocalizedString(@"SURE_MSG",@""), NSLocalizedString(@"YES_MSG",""),NSLocalizedString(@"NO_MSG",""), nil);
        if (check != 1) {
            return;
        }
        
        check = NSRunAlertPanel (NSLocalizedString(@"OPEN_HEADER_MSG", @""), NSLocalizedString(@"MAY_BE_NO_MSG",@""), NSLocalizedString(@"YES_MSG",""),NSLocalizedString(@"NO_MSG",""), nil);
        if (check != 1) {
            return;
        }
        
        check = NSRunAlertPanel (NSLocalizedString(@"OPEN_HEADER_MSG", @""), NSLocalizedString(@"OK_BUT_MSG",@""), @"OK", @"", nil);
        if (check != 1) {
            return;
        }
        //Конец проверки намерений пользователя
        
        
        NSString *selectedFile = [[newOpenPanel URL] path];
        NSError* error = nil;
        
        NSString*newGoalDnaString = [NSString stringWithContentsOfFile:selectedFile
                                                              encoding:NSUTF8StringEncoding
                                                                 error:&error];
        
        if (error != nil) {
            [self modalArlertCantOpenFile:[error localizedDescription]];
            return;
        }
        
        NSCharacterSet* checkingSet = [[NSCharacterSet characterSetWithCharactersInString:@"ATGC"]invertedSet];
        
        if ([newGoalDnaString rangeOfCharacterFromSet:checkingSet].location != NSNotFound)
        {
            [self modalArlertCantOpenFile:NSLocalizedString(@"INCORRECT_DATA_MSG", "")];
        } else if (newGoalDnaString.length !=self.DNALength) {
            
            NSString *allertMessege = [NSString stringWithFormat:NSLocalizedString(@"INCORRECT_DNA_LONG_MSG", ""),newGoalDnaString.length];
            [self modalArlertCantOpenFile:allertMessege];
        } else {
            
            NSMutableArray* myArray = [[NSMutableArray alloc]initWithCapacity:newGoalDnaString.length];
            
            for (int i=0; i < newGoalDnaString.length; i++) {
                NSString *ichar  = [NSString stringWithFormat:@"%C", [newGoalDnaString characterAtIndex:i]];
                [myArray addObject:ichar];
            }
            IDNCell *newGoalDNA= [[IDNCell alloc]init];
            newGoalDNA.arrayCapacity = [myArray count];
            newGoalDNA.DNA = myArray;
            self.goalDNA = newGoalDNA;
            [self.goalDNAField setStringValue:[self.goalDNA.DNA componentsJoinedByString:@""]];
        }
    }
}

- (IBAction)saveData:(id)sender {
    NSSavePanel *newSavePanel	= [NSSavePanel savePanel];
    [newSavePanel setAllowedFileTypes:[NSArray arrayWithObject:@"txt"]];
    [newSavePanel setAllowsOtherFileTypes:NO];
    NSInteger result = [newSavePanel runModal];
    
    if (result == NSOKButton)
    {
        
        //Начало проверки намерений пользователя
        NSInteger check = NSRunAlertPanel (NSLocalizedString(@"SAVE_HEADER_MSG", @""), NSLocalizedString(@"SURE_MSG",@""), NSLocalizedString(@"YES_MSG",""),NSLocalizedString(@"NO_MSG",""), nil);
        if (check != 1) {
            return;
        }
        
        check = NSRunAlertPanel (NSLocalizedString(@"SAVE_HEADER_MSG", @""), NSLocalizedString(@"MAY_BE_NO_MSG",@""), NSLocalizedString(@"YES_MSG",""),NSLocalizedString(@"NO_MSG",""), nil);
        if (check != 1) {
            return;
        }
        
        check = NSRunAlertPanel (NSLocalizedString(@"SAVE_HEADER_MSG", @""), NSLocalizedString(@"OK_BUT_MSG",@""), NSLocalizedString(@"YES_MSG",""), @"", nil);
        if (check != 1) {
            return;
        }
        
        //Конец проверки намерений пользователя
        
        NSString *selectedFile = [[newSavePanel URL] path];
        NSString *arrayComplete = [self.goalDNA.DNA componentsJoinedByString:@""];
        
        NSError* error =nil;
        
        [arrayComplete writeToFile:selectedFile
                        atomically:NO
                          encoding:NSUTF8StringEncoding
                             error:&error];
        if (error != nil) {
            [self modalArlertCantSaveFile:[error localizedDescription]];
        }
    }
}

#pragma mark
#pragma mark - modalAlert

- (void)modalArlertCall {
    NSAlert *alertFindDNA = [NSAlert alertWithMessageText:NSLocalizedString(@"FIND_MSG", "") defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"GENERATIN_LEFT_MSG", ""), self.workingPopulation.generationNumber];
    [alertFindDNA runModal];
}

- (void)modalArlertCantSaveFile:(NSString*)Problem {
    NSAlert *alertFindDNA = [NSAlert alertWithMessageText:NSLocalizedString(@"CANT_SAVE_MSG", "") defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", Problem];
    [alertFindDNA runModal];
}

- (void)modalArlertCantOpenFile:(NSString*)Problem {
    NSAlert *alertFindDNA = [NSAlert alertWithMessageText:NSLocalizedString(@"CANT_OPEN_MSG", "") defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", Problem];
    [alertFindDNA runModal];
}


#pragma mark
#pragma mark - random

-(void)showRandomPanel {
    self.randomGenerator = [[IDNRandomGenerator alloc]init];
    [self.randomGenerator showWindow:self];
    self.pauseStatement = false;
}

-(void) createPopulationIn {
    [self.workingPopulation createPopulationWithCount:self.populationSize andDNALength:self.DNALength];
    [self performSelectorInBackground:@selector(evolution) withObject:nil];
}

-(void)handleRandomNumberChange:(NSNotification *) notif {
    unsigned int temp = [[[notif userInfo] objectForKey:@"randomNumber"]intValue];
    [self.workingPopulation setPopulationRandomNumber:temp];
    
    if ([self.workingPopulation.population count] == 0) {
        [self createPopulationIn];
    }
    
    self.randomFlag = true;
    self.pauseStatement = true;
    
    //NSLog(@"%i", temp);
}

#pragma mark
#pragma mark - window closed

- (BOOL) windowShouldClose:(id)sender
{
    NSInteger check = NSRunAlertPanel(NSLocalizedString(@"WINDOW_CLOSE_MSG", @""), NSLocalizedString(@"SURE_MSG",@""), NSLocalizedString(@"YES_MSG",""), NSLocalizedString(@"NO_MSG",""), nil);
    
    if (check == 1) {
        if ([self.randomGenerator window]) {
            [[self.randomGenerator window] close];
        }
        self.openSaveDesible = false;
        return YES;
    }
    return NO; 
}

- (IBAction)resetPref:(id)sender {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:IDNPopulationSizePref];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:IDNDNALengthPref];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:IDNMutationPref];
}

@end
