//
//  AppDelegate.h
//  iDNA3
//

#import <Cocoa/Cocoa.h>
#import "Cell.h"
#import "PreferencesController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    BOOL            start;
    BOOL            done;
    NSInteger       generation;
    NSInteger       smallestDistance;
    NSMutableArray *population;
    NSString       *nucleoString;
}

@property (assign) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSTextField *currentGeneration;
@property (weak) IBOutlet NSTextField *bestMatch;

@property (weak) IBOutlet NSLevelIndicator     *matchIndicator;
@property (weak) IBOutlet NSLevelIndicatorCell *indicatorCell;

@property (weak) IBOutlet NSScrollView            *viewGoalDNA;
@property (unsafe_unretained) IBOutlet NSTextView *textViewGoalDNA;

@property (weak) IBOutlet NSButton *startEvolution;
@property (weak) IBOutlet NSButton *pause;
@property (weak) IBOutlet NSButton *loadGoalDNA;

@property (weak) IBOutlet NSTextField *populationField;
@property (weak) IBOutlet NSTextField *lenthField;
@property (weak) IBOutlet NSTextField *rateField;

@property (weak) IBOutlet NSSlider *populationSlider;
@property (weak) IBOutlet NSSlider *lenthSlider;
@property (weak) IBOutlet NSSlider *rateSlider;

@property NSInteger populationSize;
@property NSInteger DNALength;
@property NSInteger mutationRate;
@property Cell     *goalDNA;

- (void)setPopulationSize:(NSInteger)size DNALength:(NSInteger)length andMutationRate:(NSInteger)rate;
- (void)changePopulationnSize:(NSInteger)size orDNAString:(NSString *)string orMutationRate:(NSInteger)rate;
- (void)setSmallestDistance:(NSInteger)distance;
- (void)setGeneration:(NSInteger)gen;

- (IBAction)startEvolution:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)loadGoal:(id)sender;

- (void)performEvolutionInBackground;
- (void)mainThreadAlert;
- (void)loadAlert:(NSAlert *)alert returnCode:(int)button contextInfo:(void *)context;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context;

@end
