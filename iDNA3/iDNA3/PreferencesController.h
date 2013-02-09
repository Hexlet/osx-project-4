//
//  PreferencesController.h
//  iDNA3
//

#import <Cocoa/Cocoa.h>
#import "iDNADefine.h"

@interface PreferencesController : NSWindowController

+ (NSString *)preferencesDNAString;
+ (void)setPreferencesDNAString:(NSString *)string;
+ (NSInteger)preferencesMutateRate;
+ (void)setPreferencesMutateRate:(NSInteger)rate;
+ (NSInteger)preferencesPopulationSize;
+ (void)setPreferencesPopulationSize:(NSInteger)size;

@end
