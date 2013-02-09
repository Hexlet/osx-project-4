//
//  AppDelegate.m
//  iDNA
//
//  Created by Alexander Shvets on 24.12.12.
//  Copyright (c) 2012 Alexander Shvets. All rights reserved.
//

#import "AppDelegate.h"

#define MAX_POPULATION_SIZE 5000
#define MAX_DNA_LENGTH 300

#define APP_STATE_IDLE 0
#define APP_STATE_RUNNING 1
#define APP_STATE_PAUSED 2


@implementation AppDelegate

NSString* const keyDefaulPopulationSize = @"iDNA_defaultPopulationSize";
NSString* const keyDefaulDNALength = @"iDNA_defaultDNALength";
NSString* const keyDefaulMutationRate = @"iDNA_defaultMutationRate";

+ (void)initialize
{
    [self registerUserDefaults];
}

- (id)init
{
    if(self = [super init]){
        
        [self addObserver:self forKeyPath:@"populationSize" options:NSKeyValueObservingOptionOld context:@"populationSize"];
        [self addObserver:self forKeyPath:@"DNALength" options:NSKeyValueObservingOptionOld context:@"DNALength"];
        [self addObserver:self forKeyPath:@"mutationRate" options:NSKeyValueObservingOptionOld context:@"mutationRate"];
        
        [GrowlApplicationBridge setGrowlDelegate:self];
    }
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self appReset];
    
    randomSeedGenerated = NO;
    
    IntegerValueFormatter* formatter = [[IntegerValueFormatter alloc] init];
    [_fieldPopulationSize setFormatter:formatter];
    [_fieldDNALength setFormatter:formatter];
    [_fieldMutationRate setFormatter:formatter];
    
    [_sliderPopulationSize setMaxValue:MAX_POPULATION_SIZE];
    [_sliderDNALength setMaxValue:MAX_DNA_LENGTH];
    
    [self setPopulationSize:[self preferencesDefaultPopulationSize]];
    [self setDNALength:[self preferencesDefaultDNALength]];
    [self setMutationRate:[self preferencesDefaultMutationRate]];
    
    [_fieldGoalDNA setStringValue:[goalDNA stringValue]];
    
    [_window setDelegate:self];
    
    [self generateRandomSeed];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"populationSize"];
    [self removeObserver:self forKeyPath:@"DNALength"];
    [self removeObserver:self forKeyPath:@"mutationRate"];
}

- (void)appReset
{
    appState = APP_STATE_IDLE;
    generation = 1;
    bestMatch = 0;
    
    [self enableControls];
    
    [[[NSApplication sharedApplication] dockTile] setBadgeLabel:nil];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == @"populationSize") {
        
        if(populationSize > MAX_POPULATION_SIZE){
            populationSize = MAX_POPULATION_SIZE;
            [_fieldPopulationSize setIntegerValue:populationSize];
        } else if(populationSize < 2){
            populationSize = 2;
            [_fieldPopulationSize setIntegerValue:populationSize];
        }
        
        [self setPreferencesDefaultPopulationSize:populationSize];
        
    } else if (context == @"DNALength") {
        
        if(DNALength > MAX_DNA_LENGTH){
            DNALength = MAX_DNA_LENGTH;
            [_fieldDNALength setIntegerValue:DNALength];
        } else if(DNALength < 1){
            DNALength = 1;
            [_fieldDNALength setIntegerValue:DNALength];
        }
        
        [self buildGoalDNAWithLength: DNALength];
        [self setPreferencesDefaultDNALength:DNALength];

    } else if (context == @"mutationRate") {
        
        if(mutationRate < 1){
            mutationRate = 1;
            [_fieldMutationRate setIntValue:mutationRate];
        } else if(mutationRate > 100){
            mutationRate = 100;
            [_fieldMutationRate setIntValue:mutationRate];
        }
        
        [self setPreferencesDefaultMutationRate:mutationRate];
    
    }
    
}

- (void)setPopulationSize:(int)size
{
    populationSize = size;
}

- (void)setDNALength:(int)length
{
    DNALength = length;
}

- (void)setMutationRate:(int)rate
{
    mutationRate = rate;
}

- (void)buildGoalDNAWithLength:(int) length
{
    goalDNA = [[Cell alloc] initWithLength:length];
    [_fieldGoalDNA setStringValue:[goalDNA stringValue]];
}


- (IBAction)startEvolution:(id)sender {
    [self disableControls];
    
    if(appState != APP_STATE_PAUSED){
        population = [[Population alloc] initWithPopulationSize:populationSize andDNALength:DNALength];
        NSLog(@"New population created. Simulation started.");
    } else {
        NSLog(@"Simulation continue");
    }
    
    appState = APP_STATE_RUNNING;
    
    //start background evolution
    NSThread* bgEvolutionThread = [[NSThread alloc] initWithTarget:self selector:@selector(evolution) object:nil];
    [bgEvolutionThread start];
}

- (void) evolution
{
    
    do {
        @autoreleasepool { //устраняем утечку памяти в цикле
            
            // пересчитать расстояние Хэминга для каждой клетки в популяции
            [population hammingDistanceWith:goalDNA];
            
            // отсортировать популяцию по расстоянию Хэминга
            [population sort];
            
            // процент сходства лучшей клетки с целевой ДНК
            float bestPopulationDistance = DNALength - [[population.cells objectAtIndex:0] hammingDistance];
            float matchPercent = (bestPopulationDistance / DNALength) * 100;
            
            // обновление статистики (если необходимо)
            if((int)matchPercent > bestMatch){
                bestMatch = (int)matchPercent;
                [_progressMatch setIntValue:bestMatch];
                [_labelBestMatch setStringValue:[NSString
                                                 stringWithFormat:NSLocalizedString(@"LCD_BEST_MATCH", nil), bestMatch]];
                
                [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"%i%%", bestMatch]];
                
                NSLog(@"\nNew best match: %i%% \nBest DNA: %@", bestMatch, [[population.cells objectAtIndex:0] stringValue]);
            }
             
            // проверка на успешное завершение эволюции
            if(![population evolutionSuccess]){
                
                // скрестить кандидатов из топ 50% и заменить результатом оставшиеся 50%
                if(DNALength >= 2) [population hybridize];
                
                // мутировать получившуюся популяцию
                [population mutate:mutationRate];
                
                generation++;
                [_labelGeneration setStringValue:[NSString
                                                  stringWithFormat:NSLocalizedString(@"LCD_GENERATION", nil), generation]];
                
            } else { // эволюция завершена
                
                [_labelBestMatch setStringValue:NSLocalizedString(@"LCD_EVOLUTION_COMPLETE", nil)];
                [NSApp requestUserAttention:NSCriticalRequest];
                NSBeep();
                
                // Creating growl notification
                [GrowlApplicationBridge
                     notifyWithTitle:@"iDNA"
                     description:[NSString stringWithFormat:NSLocalizedString(@"GROWL_MSG", nil), generation]
                     notificationName:@"iDNA"
                     iconData: nil
                     priority:1
                     isSticky:NO
                     clickContext:@"showApp"];
            
                appState = APP_STATE_IDLE;
                [self appReset];
                
                NSLog(@"JOB DONE!!!!");
      
            }
            
        }
    } while(appState == APP_STATE_RUNNING);
    
}

- (IBAction)pauseEvolution:(id)sender {
    if([[sender title] isEqualToString:NSLocalizedString(@"BTN_PAUSE", nil)]){
        //pause
        appState = APP_STATE_PAUSED;
        [sender setTitle:NSLocalizedString(@"BTN_CONTINUE", nil)];
        
    } else {
        //resume
        [self startEvolution:nil];
        [sender setTitle:NSLocalizedString(@"BTN_PAUSE", nil)];
    }
}

- (void)disableControls
{
    [_fieldPopulationSize setEnabled:NO];
    [_fieldDNALength setEnabled:NO];
    [_sliderPopulationSize setEnabled:NO];
    [_sliderDNALength setEnabled:NO];
    [_btnStart setEnabled:NO];
    [_btnLoad setEnabled:NO];
    [_btnPause setEnabled:YES];
}

- (void)enableControls
{
    [_fieldPopulationSize setEnabled:YES];
    [_fieldDNALength setEnabled:YES];
    [_sliderPopulationSize setEnabled:YES];
    [_sliderDNALength setEnabled:YES];
    [_btnStart setEnabled:YES];
    [_btnLoad setEnabled:YES];
    [_btnPause setEnabled:NO];
}

- (IBAction)loadGoalDNA:(id)sender {
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setAllowedFileTypes:[NSArray arrayWithObjects:@"txt", @"dna", nil]];
    [openDlg setAllowsMultipleSelection:NO];
    
    if([openDlg runModal] == NSOKButton){
        NSArray* files = [openDlg URLs];
        NSString* filePath = [[files objectAtIndex:0] path];
        
        if(filePath){
            NSString* fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            NSString* dnaString = [self validateDNAString:fileContents];
            NSLog(@"File DNA: %@", dnaString);
            
            if([dnaString length]){
                [self setDNALength:(int)[dnaString length]];
                [_fieldGoalDNA setStringValue:dnaString];
                
                //goalDNA = nil;
                goalDNA = [[Cell alloc ] initWithString:dnaString];
                NSLog(@"Loaded goal DNA: %@", [goalDNA stringValue]);
                
            } else {
                NSAlert *alert = [[NSAlert alloc] init];
                [alert setMessageText:NSLocalizedString(@"ALERT_WRONG_DNA_FORMAT", nil)];
                [alert beginSheetModalForWindow:_window modalDelegate:self didEndSelector:nil contextInfo:nil];
            }
            
        }
    }
    
}

// проверка загруженой из файла ДНК.
// удаление неправильных символов (не C,G,T,A). это позволяет скормить приложению любой текстовый файл.
// обрезать ДНК до максимально возможной длины
- (NSString*)validateDNAString:(NSString*)DNAString
{
    NSArray* nucleotides = [[Nucleotides sharedInstance] getNucleotides];
    NSString* dnaString = @"";
    NSString* singleChar = @"";
    
    for(int i = 0; i < [DNAString length]; i++){
        singleChar = [[DNAString substringWithRange:NSMakeRange(i,1)] uppercaseString];
        if([nucleotides containsObject:singleChar]){
            dnaString = [dnaString stringByAppendingString:singleChar];
        }
        
        if([dnaString length] >= MAX_DNA_LENGTH) break;
    }
    
    return dnaString;
}


//инициализация генератора случайных чисел на основе движения мыши
- (void)generateRandomSeed
{
    [NSApp beginSheet:_randomProgressPanel
       modalForWindow:_window
        modalDelegate:self
       didEndSelector:nil contextInfo:nil];
    
    __block double progress = 0;
    __block int seed = 0;
    __block id mouseTracker = [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^(NSEvent* mouseEvent) {
        if(progress < 100){
            NSPoint point = [mouseEvent locationInWindow];
            seed = seed + (point.x * point.y);
            progress += .5;
            
            [_randomProgressBar setDoubleValue:progress];
        } else {
            [NSEvent removeMonitor:mouseTracker];
            
            [NSApp endSheet:_randomProgressPanel];
            [_randomProgressPanel orderOut:_window];
            
            srandom(seed);
            NSLog(@"Random number seeded");
        }
    }];
}


// подтверждение выхода из приложения в процессе эволюции
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    if(appState != APP_STATE_IDLE){
        [self showExitConfirmation];
        return NSTerminateCancel;
    }
    return NSTerminateNow;
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (BOOL) windowShouldClose:(id)sender
{
    if(appState != APP_STATE_IDLE){
        [self showExitConfirmation];
        return NO;
    }
    return YES;
}

- (void) showExitConfirmation
{
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"ALERT_CONFIRMATION_TITLE", nil)
                                     defaultButton:NSLocalizedString(@"BTN_YES", nil)
                                   alternateButton:NSLocalizedString(@"BTN_NO", nil) otherButton:nil
                         informativeTextWithFormat:NSLocalizedString(@"ALERT_CONFIRMATION_TEXT", nil)];
    [alert beginSheetModalForWindow:_window modalDelegate:self didEndSelector:@selector(alertDidEnd:code:context:) contextInfo:nil];
}

- (void) alertDidEnd:(NSAlert*)alert code:(NSInteger)choice context:(void*)context
{
    if(choice == NSAlertDefaultReturn){
        appState = APP_STATE_IDLE;
        //[_window close];
        [NSApp terminate:nil];
    }
}


// Growl delegate methods
- (void) growlNotificationWasClicked:(id)context
{
    // активируем окно приложения при клике на growl сообщении
    [NSApp activateIgnoringOtherApps:YES];
    [_window makeKeyAndOrderFront:nil];
}

- (NSDictionary *) registrationDictionaryForGrowl
{
    NSArray *notifications = [NSArray arrayWithObject: @"iDNA"];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          notifications, GROWL_NOTIFICATIONS_ALL,
                          notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
    
    return dict;
}


// работа с пользовательскими настройками (запись/чтение)
+ (void)registerUserDefaults
{
    NSMutableDictionary *defaulValues = [NSMutableDictionary dictionary];
    [defaulValues setObject:[NSNumber numberWithInt:1000] forKey:keyDefaulPopulationSize];
    [defaulValues setObject:[NSNumber numberWithInt:50] forKey:keyDefaulDNALength];
    [defaulValues setObject:[NSNumber numberWithInt:10] forKey:keyDefaulMutationRate];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaulValues];
}

- (int)preferencesDefaultPopulationSize{
    return (int)[[[NSUserDefaults standardUserDefaults] objectForKey:keyDefaulPopulationSize] integerValue];
}

- (void)setPreferencesDefaultPopulationSize:(int)size
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:size] forKey:keyDefaulPopulationSize];
}

- (int)preferencesDefaultDNALength
{
    return (int)[[[NSUserDefaults standardUserDefaults] objectForKey:keyDefaulDNALength] integerValue];
}

- (void)setPreferencesDefaultDNALength:(int)length
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:length] forKey:keyDefaulDNALength];
}

- (int)preferencesDefaultMutationRate
{
    return (int)[[[NSUserDefaults standardUserDefaults] objectForKey:keyDefaulMutationRate] integerValue];
}

- (void)setPreferencesDefaultMutationRate:(int)rate
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:rate] forKey:keyDefaulMutationRate];
}


@end