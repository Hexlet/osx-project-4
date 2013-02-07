//
//  AppDelegate.m
//  iDNA
//
//  Created by Admin on 23.12.12.
//  Copyright (c) 2012 Kabest. All rights reserved.
//

#import "AppDelegate.h"
#import "PreferencesController.h"
#import "RandomGenWindowController.h"

#define EVOLUTION_DONE_NOTIFICATION @"iDNAEvolutionDoneNotification"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.goalDNATextField setStringValue:[self.goalDNA stringValue]];
    self.isRunning = NO;
    // подпишемся на событие обокончании очередной эволюции
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(evolutionDone:) name:EVOLUTION_DONE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRandomNumberReady:) name:IDNARandomNumberReady object:nil];
}

-(id)init {
    self = [super init];
    if (self) {
        self.preferences = [[PreferencesController alloc] init];
        
        [self addObserver:self forKeyPath:@"populationSize" options:0 context:nil];
        [self addObserver:self forKeyPath:@"dnaLength" options:0 context:nil];
        [self addObserver:self forKeyPath:@"mutationRate" options:0 context:nil];
        [self addObserver:self forKeyPath:@"minimumHammingDistance" options:0 context:nil];
        
        self.populationSize = [self.preferences populationSize];
        self.dnaLength = [self.preferences DNALength];
        self.mutationRate = [self.preferences mutationRate];
        self.generation = 0;
        self.bestIndividualMatch = 0;
        self.population = [NSMutableArray array];
        self.isFirstRun = YES;
        self.isRunning = NO;
        
        self.goalDNA = [[Cell alloc] initWithCapacity:self.dnaLength];
    }
    return self;
}

-(void)dealloc {
    [self removeObserver:self forKeyPath:@"populationSize"];
    [self removeObserver:self forKeyPath:@"dnaLength"];
    [self removeObserver:self forKeyPath:@"mutationRate"];
    [self removeObserver:self forKeyPath:@"minimumHammingDistance"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EVOLUTION_DONE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IDNARandomNumberReady object:nil];
}

-(void)doEvolutionThread {
    // если мы запустили процесс, то выполним очередной шаг эволюции в отдельном потоке
    if (self.isRunning) {
        [self performSelectorInBackground:@selector(doEvolution) withObject:nil];
    }
}

-(void)evolutionGoalReached {
    // достигли целевой ДНК
    self.isRunning = NO;
    self.isFirstRun = YES;
}

- (void)evolutionDone:(NSNotification *)aNotification {
    // если получили извещение об окончании очередного шага эволюции,
    // то запустим следующий шаг (если, конечно, процесс не остановлен)
    if (aNotification && [[aNotification name] isEqualToString:EVOLUTION_DONE_NOTIFICATION])
        [self doEvolutionThread];
}

-(void)doEvolution {
    // Эволюция:
    self.generation++;
    //  сортируем популяцию по hammingDistance до целевой ДНК
    [self.population sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Cell *dna1 = (Cell*)obj1;
        Cell *dna2 = (Cell*)obj2;
        NSInteger hammingDistance1 = [dna1 hammingDistance:self.goalDNA];
        NSInteger hammingDistance2 = [dna2 hammingDistance:self.goalDNA];
        if (hammingDistance1 < hammingDistance2)
            return NSOrderedAscending;
        else if (hammingDistance1 > hammingDistance2)
            return NSOrderedDescending;
        else
            return NSOrderedSame;
    }];
    //  при непустой популяции первым элементом будет самая близкая к целевой ДНК
    if (self.population.count > 0) {
        self.minimumHammingDistance = [[self.population objectAtIndex:0] hammingDistance:self.goalDNA];
        // полученная и целевая ДНК полностью совпадают, остановим эволюцию
        if (self.minimumHammingDistance == 0) {
            self.isRunning = NO;
            [self performSelectorOnMainThread:@selector(evolutionGoalReached) withObject:nil waitUntilDone:YES];
            return;
        }
    }
    
    //  выберем из топ 50% популяции две произвольные ДНК
    NSInteger pos1 = arc4random() % (self.populationSize/2);
    NSInteger pos2 = 0;
    do {
        pos2 = arc4random() % (self.populationSize/2);
    } while (pos1 == pos2);
    Cell *dna1 = [self.population objectAtIndex:pos1];
    Cell *dna2 = [self.population objectAtIndex:pos2];
    //  получим новую ДНК путем скрещивания
    Cell *newDNA = [dna1 crossBreedingWith:dna2];
    //  и заменим полученной оставшиеся 50% популяции
    for (int i = self.populationSize/2; i < self.populationSize; i++)
        [self.population replaceObjectAtIndex:i withObject:newDNA];
    
    //  теперь полностью мутируем популяцию
    for (Cell *dna in self.population)
        [dna mutateDNA:self.mutationRate];
    
    // шаг эволюции завершен, уведомим об этом
    [[NSNotificationCenter defaultCenter] postNotificationName:EVOLUTION_DONE_NOTIFICATION object:self];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ((object == self) && keyPath) {
        if ([keyPath isEqualToString:@"populationSize"]) {
            // при изменении размера популяции установим флаг первого запуска,
            // чтобы при нажатии кнопки "Старт эволюции" инициализировать популяцию заново
            self.isFirstRun = YES;
            // сохраним изменение в настройках приложения
            [self.preferences setPopulationSize:self.populationSize];
        }
        else if ([keyPath isEqualToString:@"dnaLength"]) {
            // при изменении длины цепочки ДНК пересоздадим ее
            self.goalDNA = [[Cell alloc] initWithCapacity:self.dnaLength];
            // и также установим флаг первого запуска для последующей инициализации
            self.isFirstRun = YES;
            // обновим текстовое поле с ДНК
            [self.goalDNATextField setStringValue:[self.goalDNA stringValue]];
            // сохраним изменение в настройках приложения
            [self.preferences setDNALength:self.dnaLength];
        }
        else if ([keyPath isEqualToString:@"minimumHammingDistance"]) {
            // выразим расстояние до целевой ДНК в процентах
            if (self.dnaLength > 0) {
                NSUInteger newIndividualMatch = 100*(1 - self.minimumHammingDistance*1.0/self.dnaLength);
                if (newIndividualMatch > self.bestIndividualMatch)
                    self.bestIndividualMatch = newIndividualMatch;
            }
        }
        else if ([keyPath isEqualToString:@"mutationRate"]) {
            // сохраним изменение в настройках приложения
            [self.preferences setMutationRate:self.mutationRate];
        }
        else
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

-(IBAction)startEvolutionButtonClicked:(id)sender {
    // при первом запуске сбросим номер поколения и создадим популяцию
    if (self.isFirstRun) {
        _randomWindow = [[RandomGenWindowController alloc] initWithWindowNibName:@"RandomGenWindowController"];
        
        [NSApp beginSheet:[_randomWindow window] modalForWindow:[self window] modalDelegate:_randomWindow didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
        [NSApp runModalForWindow:[_randomWindow window]];
        [NSApp endSheet:[_randomWindow window]];
        [[_randomWindow window] orderOut:self];
    }
    else
        [self startEvolution];
}

-(IBAction)pauseEvolutionButtonClicked:(id)sender {
    // приостанавливаем, но isFirstRun не меняем, он сбросится, если изменим параметры эволюции
    self.isRunning = NO;
    self.window.title = NSLocalizedString(@"IDNA_TITLE", @"iDNA");
}

-(void)onRandomNumberReady:(NSNotification*)notification {
    NSNumber *rndNumber = [[notification userInfo] objectForKey:IDNARandomNumber];
    srandom([rndNumber unsignedIntValue]);
    
    [self initEvolution];
    [self startEvolution];
}

-(void)initEvolution {
    // инициализируем
    self.generation = 0;
    self.bestIndividualMatch = 0;
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.populationSize];
    for (int i = 0; i < self.populationSize; i++) {
        Cell *dna = [[Cell alloc] initWithCapacity:self.dnaLength];
        [arr addObject:dna];
    }
    self.population = arr;
}

-(void)startEvolution {
    // запускаем
    self.isRunning = YES;
    self.isFirstRun = NO;
    self.window.title = NSLocalizedString(@"IDNA_IS_RUNNING_TITLE", @"iDNA is running...");
    [self doEvolutionThread];
}

-(IBAction)loadGoalDNAButtonClicked:(id)sender {
    // загрузка целевой ДНК из текстового файла
    NSInteger res = NSRunAlertPanel(NSLocalizedString(@"LOAD_TITLE", @"Load DNA from file?"), NSLocalizedString(@"LOAD_TEXT", @"Do you really want to load DNA from file?"), NSLocalizedString(@"BUTTON_YES", @"Yes"), NSLocalizedString(@"BUTTON_NO", @"No"), nil);
    if (res == NSAlertDefaultReturn) {
        NSOpenPanel *dnaOpenPanel = [NSOpenPanel openPanel];
        NSInteger res = [dnaOpenPanel runModal];
        if (res == NSOKButton) {
            NSURL *url = [dnaOpenPanel URL];
            NSString *s = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
            [self.goalDNATextField setStringValue:s];
        }
    }
}

-(IBAction)saveGoalDNAButtonClicked:(id)sender {
    // сохранение целевой ДНК в текстовый файл
    NSInteger res = NSRunAlertPanel(NSLocalizedString(@"SAVE_TITLE", @"Save DNA to file?"), NSLocalizedString(@"SAVE_TEXT", @"Do you really want to save DNA to file?"), NSLocalizedString(@"BUTTON_YES", @"Yes"), NSLocalizedString(@"BUTTON_NO", @"No"), nil);
    if (res == NSAlertDefaultReturn) {
        NSSavePanel *dnaSavePanel = [NSSavePanel savePanel];
        NSInteger res = [dnaSavePanel runModal];
        if (res == NSOKButton) {
            NSURL *url = [dnaSavePanel URL];
            NSString *s = [self.goalDNATextField stringValue];
            [s writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return NO;
}

-(NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    if (self.isRunning) {
        NSInteger res = NSRunAlertPanel(NSLocalizedString(@"EXIT_TITLE", @"Quit iDNA?"), NSLocalizedString(@"EXIT_TEXT", @"Calculation is in progress! Do you want to quit iDNA?"), NSLocalizedString(@"BUTTON_YES", @"Yes"), NSLocalizedString(@"BUTTON_NO", @"No"), nil);
        if (res == NSAlertDefaultReturn)
            return NSTerminateNow;
        else
            return NSTerminateCancel;
    }
    else
        return NSTerminateNow;
}


@end
