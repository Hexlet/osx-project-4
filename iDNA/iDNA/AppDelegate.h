#import <Cocoa/Cocoa.h>
#import "EvolutionProgressDelegate.h"
@class Evolution;

@interface AppDelegate : NSObject <NSApplicationDelegate, EvolutionProgressDelegate, NSWindowDelegate> {
    Evolution *evolution;
    IBOutlet NSTextField *generationLabel;
    IBOutlet NSTextField *bestMatchLabel;
    IBOutlet NSLevelIndicator *progressIndicator;
}

@property (assign) IBOutlet NSWindow *window;
@property Evolution *evolution;
@property (readonly) BOOL canChangeParams;
@property (readonly) NSString *startStopButtonTitle;
@property (readonly) NSString *pauseResumeButtonTitle;
@property (readonly) BOOL pauseResumeButtonIsEnabled;

-(IBAction)startStopEvolution:(id)sender;
-(IBAction)pauseResumeEvolution:(id)sender;

-(IBAction)loadGoalDNAFromFile:(id)sender;

@end
