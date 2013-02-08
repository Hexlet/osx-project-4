//
//  AppDelegate.m
//  iDNA3
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window;
//NSTextField
@synthesize currentGeneration;
@synthesize bestMatch;
//NSLevelIndicator
@synthesize matchIndicator;
@synthesize indicatorCell;
//NSScrollView
@synthesize viewGoalDNA;
@synthesize textViewGoalDNA;
//NSButton
@synthesize startEvolution;
@synthesize pause;
@synthesize loadGoalDNA;
//NSTextField
@synthesize populationField;
@synthesize lenthField;
@synthesize rateField;
//NSSlider
@synthesize populationSlider;
@synthesize lenthSlider;
@synthesize rateSlider;
//
@synthesize populationSize;
@synthesize DNALength;
@synthesize mutationRate;
@synthesize goalDNA;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    [self setPopulationSize:[PreferencesController preferencesPopulationSize]
                  DNALength:[[PreferencesController preferencesDNAString] length]
            andMutationRate:[PreferencesController preferencesMutateRate]];
    
    [self addObserver:self forKeyPath:@"DNALength" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"populationSize" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"mutationRate" options:NSKeyValueObservingOptionNew context:nil];
    
    [self pause:self];                      //  [pause setEnabled: NO];
    [window makeFirstResponder: nil];       //  disable focus
    
}


- (void)setPopulationSize:(NSInteger)size DNALength:(NSInteger)length andMutationRate:(NSInteger)rate
{
    start = NO;
    done = YES;

    size = size >= 4 ? size : 4;
    length = length >= 5 ? length : 5;
    rate = rate > 0 ? rate : 1;
    rate = rate < 99 ? rate : 99;
    
    [self setValue:[NSNumber numberWithInteger:size] forKey: @"populationSize"];
    [self setValue:[NSNumber numberWithInteger:length] forKey: @"DNALength"];
    [self setValue:[NSNumber numberWithInteger: rate] forKey: @"mutationRate"];
    
    population = [NSMutableArray arrayWithCapacity:size];
    
    [self setSmallestDistance: DNALength];
    [self setGeneration: 1];
    
    goalDNA = [[Cell alloc] initWithDNALength:length];
    
    [textViewGoalDNA setString:goalDNA.nucleo];
}


- (void)changePopulationnSize:(NSInteger)size orDNAString:(NSString *)string orMutationRate:(NSInteger)rate
{
    start = NO;
    done = YES;
    
    [self setValue:[NSNumber numberWithInteger:size] forKey: @"populationSize"];
    [self setValue:[NSNumber numberWithInteger:[string length]] forKey: @"DNALength"];
    [self setValue:[NSNumber numberWithInteger: rate] forKey: @"mutationRate"];
    
    population = [NSMutableArray arrayWithCapacity:size];
    
    [self setSmallestDistance: DNALength];
    [self setGeneration: 1];
    
    [goalDNA changeDNAString:string];
    
    [textViewGoalDNA setString:goalDNA.nucleo];
}


- (void)setSmallestDistance:(NSInteger)distance
{
    NSInteger percent = (DNALength - distance) *100 / DNALength;
    
    [bestMatch setStringValue:[NSString stringWithFormat: NSLocalizedString(@"BEST_MATCH", "Best match"), percent]];  // [bestMatch setStringValue:[NSString stringWithFormat: @"Best individual match - %ld%%", percent]];
    [matchIndicator setIntegerValue: percent];
    smallestDistance = distance;
}


- (void)setGeneration:(NSInteger)gen
{
    [currentGeneration setStringValue:[NSString stringWithFormat: NSLocalizedString(@"GENERATION", "Generation"), gen]];    // [currentGeneration setStringValue:[NSString stringWithFormat: @"Generation: %ld", gen]];
    generation = gen;
}


- (IBAction)startEvolution:(id)sender
{ 
    [self performSelectorInBackground:@selector(performEvolutionInBackground) withObject:nil];
}


- (IBAction)pause:(id)sender
{
    start = NO;
    
    [pause setEnabled: NO];
    [startEvolution setEnabled: YES];
    [loadGoalDNA setEnabled: YES];
    
    [populationField setEnabled: YES];
    [lenthField setEnabled: YES];
    [rateField setEnabled: YES];
    
    [populationSlider setEnabled: YES];
    [lenthSlider setEnabled: YES];
    [rateSlider setEnabled: YES];
}


- (IBAction)loadGoal:(id)sender
{
    NSString *string = [PreferencesController preferencesDNAString];
    if ([[goalDNA DNAString] length] != [string length])
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:NSLocalizedString(@"PROCEED", "Proceed")];            // [alert addButtonWithTitle:@"Proceed"];
        [alert addButtonWithTitle:NSLocalizedString(@"CANCEL", "Cancel")];              // [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:NSLocalizedString(@"MISMATCH_DNA", "Different size")];    // [alert setMessageText:@"New DNA has different size!"];
        [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(loadAlert:returnCode:contextInfo:) contextInfo:nil];
    }
    else
    {
        [self changePopulationnSize:[PreferencesController preferencesPopulationSize]
                        orDNAString:[PreferencesController preferencesDNAString]
                     orMutationRate:[PreferencesController preferencesMutateRate]];
    }
}


- (void)performEvolutionInBackground
{
    start = YES;

    [pause setEnabled: YES];
    [startEvolution setEnabled: NO];
    [loadGoalDNA setEnabled: NO];
    
    [populationField setEnabled: NO];
    [lenthField setEnabled: NO];
    [rateField setEnabled: NO];
    
    [populationSlider setEnabled: NO];
    [lenthSlider setEnabled: NO];
    [rateSlider setEnabled: NO];
    
    NSPoint mlPoint = [NSEvent mouseLocation];
    
    while (mlPoint.x == [NSEvent mouseLocation].x || mlPoint.y == [NSEvent mouseLocation].y);
    
    float distance = sqrtf((mlPoint.x - [NSEvent mouseLocation].x) * (mlPoint.x - [NSEvent mouseLocation].x) + (mlPoint.y - [NSEvent mouseLocation].y) * (mlPoint.y - [NSEvent mouseLocation].y)) * 100;
    
//    NSLog(@"Distance = %f", distance);
    
    srandom((unsigned)distance);
    
    if (generation == 1 || done == YES)
    {
        done = NO;
        [self setGeneration:1];
        
        for (int i = 0; i < populationSize; i++) population[i] = [[Cell alloc] initWithBaseCell:goalDNA andMutationPercents:mutationRate];
    }

    [self setSmallestDistance:[population[0] humming]];
    
	while (start)
    {
        population = [Cell sort:population];
        
        [self setSmallestDistance:[population[0] humming]];
        
        if ([population[0] humming] == 0)
        {
            done = YES;
            break;
        }
        
        int i = populationSize / 2;
        
        do
        {
            int indexA = random() % (populationSize / 2);
            int indexB;
            
            while ((indexB = random() % (populationSize / 2)) == indexA);
            
            [population[i] matingWithParrentA:population[indexA] andParrentB:population[indexB]];
        }
        while (start && [population[i] hummingDistance:goalDNA] != 0 && ++i < populationSize);
        

        if (start) [self setGeneration:++generation];
	}
    
	start = NO;
    
    [self performSelectorOnMainThread:@selector(mainThreadAlert) withObject:nil waitUntilDone:NO];
}


- (void)mainThreadAlert
{
    [self pause:self];
    
    if (done)
    {
        NSString *info;
        NSAlert  *alert = [[NSAlert alloc] init];
        
        switch (generation)
        {
            case 1:     info = NSLocalizedString(@"GENERATION_1", "1th");   // @"1th";
                break;
                
            case 2:     info = NSLocalizedString(@"GENERATION_2", "2nd");   // @"2nd";
                break;
                
            case 3:     info = NSLocalizedString(@"GENERATION_3", "3rd");   // @"3rd";
                break;
                
            default:    info = [NSString stringWithFormat:NSLocalizedString(@"GENERATION_NXT", "...th"), generation];   // [NSString stringWithFormat:@"%ldth", generation];
        }
        
        [alert addButtonWithTitle:NSLocalizedString(@"OK", "Ok")];                                                      // [alert addButtonWithTitle:@"Ok"];
        [alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"MATCH_REATCHED", "Match reached"), info]]; // [alert setMessageText:[NSString stringWithFormat:@"Total match reached at %@ generation", info]];
        [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
    }
}


- (void)loadAlert:(NSAlert *)alert returnCode:(int)button contextInfo:(void *)context
{
    if (button == NSAlertFirstButtonReturn)   // Proceed
    {
        [self changePopulationnSize:[PreferencesController preferencesPopulationSize]
                        orDNAString:[PreferencesController preferencesDNAString]
                     orMutationRate:[PreferencesController preferencesMutateRate]];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath compare:@"DNALength"] == NSOrderedSame)
    {
        [goalDNA changeDNALength:DNALength];
        [textViewGoalDNA setString:goalDNA.nucleo];
    }
    
    done = YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"WANT_QUIT", "want to quit?")
                                         defaultButton:NSLocalizedString(@"_YES_", "Yes")
                                       alternateButton:NSLocalizedString(@"_NO_", "No")
                                           otherButton:nil
                             informativeTextWithFormat:@""];
    
        [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:@selector(quitAlert:returnCode:contextInfo:) contextInfo:nil];
    
        return NSTerminateLater;
}

- (void)quitAlert:(NSAlert *)alert returnCode:(int)button contextInfo:(void *)context
{
    
    [NSApp replyToApplicationShouldTerminate: (button == NSAlertDefaultReturn) ? NSTerminateNow : NSTerminateCancel];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [PreferencesController setPreferencesDNAString:[goalDNA DNAString]];
    [PreferencesController setPreferencesMutateRate:mutationRate];
    [PreferencesController setPreferencesPopulationSize:populationSize];
}

@end
