#import "AppDelegate.h"
#import "Evolution.h"

@implementation AppDelegate

@synthesize evolution;

-(id)init {
    self = [super init];
    if (self) {
        [[self class] registerDefaultSettings];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        evolution = [[Evolution alloc] init];
        [evolution setDelegate:self];
        for (NSString *evolutionParam in @[ @"populationSize", @"dnaLength", @"mutationRate" ]) {
            [evolution setValue:[defaults objectForKey:evolutionParam] forKey:evolutionParam];
            [evolution addObserver:self forKeyPath:evolutionParam options:NSKeyValueObservingOptionNew context:nil];
        }
    }
    return self;
}

+(void)registerDefaultSettings {
    NSDictionary *defaultSettings = @{
        @"populationSize": @100,
        @"dnaLength": @20,
        @"mutationRate": @10
    };
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultSettings];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object != evolution) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:change[@"new"] forKey:keyPath];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.window setDelegate:self];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

-(BOOL)windowShouldClose:(id)sender {
    NSAlert *alertWindow = [NSAlert alertWithMessageText:NSLocalizedString(@"QUIT_MSG", "Quit iDNA")
                                           defaultButton:NSLocalizedString(@"YES", @"Yes")
                                         alternateButton:NSLocalizedString(@"NO", @"No")
                                             otherButton:nil
                               informativeTextWithFormat:NSLocalizedString(@"QUIT_TEXT", @"Do you really want to exit?")];
    if ([alertWindow runModal] == NSAlertDefaultReturn) {
        return YES;
    }
    return NO;
}

-(IBAction)startStopEvolution:(id)sender {
    [self willChangeState];
    if (evolution.inProgress) {
        [evolution stop];
    } else {
        [evolution start];
    }
    [self didChangeState];
}

-(IBAction)pauseResumeEvolution:(id)sender {
    [self willChangeState];
    if (evolution.paused) {
        [evolution resume];
    } else {
        [evolution pause];
    }
    [self didChangeState];
}

-(void)willChangeState {
    [self willChangeValueForKey:@"canChangeParams"];
    [self willChangeValueForKey:@"startStopButtonTitle"];
    [self willChangeValueForKey:@"pauseResumeButtonTitle"];
    [self willChangeValueForKey:@"pauseResumeButtonIsEnabled"];
}

-(void)didChangeState {
    [self didChangeValueForKey:@"canChangeParams"];
    [self didChangeValueForKey:@"startStopButtonTitle"];
    [self didChangeValueForKey:@"pauseResumeButtonTitle"];
    [self didChangeValueForKey:@"pauseResumeButtonIsEnabled"];
}

-(BOOL)canChangeParams {
    return evolution.inProgress == NO;
}

-(NSString *)startStopButtonTitle {
    return evolution.inProgress ? NSLocalizedString(@"STOP", @"Stop evolution") : NSLocalizedString(@"START",  @"Start evolution");
}

-(NSString *)pauseResumeButtonTitle {
    return evolution.paused ? NSLocalizedString(@"RESUME", @"Resume") : NSLocalizedString(@"PAUSE",  @"Pause");
}

-(BOOL)pauseResumeButtonIsEnabled {
    return evolution.inProgress == YES;
}

-(void)evolutionStateHasChanged:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    [generationLabel setStringValue:[NSString stringWithFormat:@"%@", [userInfo objectForKey:@"generation"]]];
    NSNumber *bestMatch = [userInfo objectForKey:@"bestMatch"];
    [bestMatchLabel setStringValue:[NSString stringWithFormat:@"%@%%", bestMatch]];
    [progressIndicator setDoubleValue: [bestMatch doubleValue]];
}

-(void)evolutionGoalIsReached {
    [self willChangeState];
    [self didChangeState];
}

-(IBAction)loadGoalDNAFromFile:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    if (![openPanel runModal] == NSFileHandlingPanelOKButton) {
        return;
    }
    
    NSString *errorText = nil;
    NSString *dnaString = [NSString stringWithContentsOfURL:[openPanel URL] usedEncoding:nil error:nil];
    NSPredicate *dnaStringPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[ATGC]+"];
    
    if (dnaString == nil) {
        errorText = NSLocalizedString(@"FILE_READ_ERROR", @"Cannot read the file");
    } else if (![dnaStringPredicate evaluateWithObject:dnaString]) {
        errorText = NSLocalizedString(@"FILE_FORMAT_ERROR", @"Text from the file is not DNA");
    } else if ([dnaString length] < 4) {
        errorText = NSLocalizedString(@"TOO_SHORT_DNA_ERROR", @"DNA is too short");
    } else if ([dnaString length] > 100) {
        errorText = NSLocalizedString(@"TOO_LONG_DNA_ERROR", @"DNA is too long");
    }

    if (errorText) {
        [self showAlertWithMessageText:@"Ops" informativeText:errorText];
        return;
    }
    
    NSAlert *alertWindow = [NSAlert alertWithMessageText:NSLocalizedString(@"OPEN_FILE_MSG", @"Open file")
                                           defaultButton:NSLocalizedString(@"YES", @"Yes")
                                         alternateButton:NSLocalizedString(@"NO", @"No")
                                             otherButton:nil
                               informativeTextWithFormat:NSLocalizedString(@"REPLACE_TEXT", @"Do you really want replace current goal DNA with DNA from file?")];
    if ([alertWindow runModal] != NSAlertDefaultReturn) {
        return;
    }
    
    [evolution loadGoalDNA:dnaString];
}

-(void)showAlertWithMessageText:(NSString *)text informativeText:(NSString *)informativeText {
    NSAlert *alert = [NSAlert alertWithMessageText:text defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", informativeText];
    [alert runModal];
}

@end
