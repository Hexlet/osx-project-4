//
//  PreferencesController.h
//  iDNA3
//

#import <Cocoa/Cocoa.h>


#define iDNAstring     @"nucleoString"
#define iDNARate       @"mutationRate"
#define iDNAPopulation @"populationSize"

@interface PreferencesController : NSWindowController

+ (NSString *)preferencesDNAString;
+ (void)setPreferencesDNAString:(NSString *)string;
+ (NSInteger)preferencesMutateRate;
+ (void)setPreferencesMutateRate:(NSInteger)rate;
+ (NSInteger)preferencesPopulationSize;
+ (void)setPreferencesPopulationSize:(NSInteger)size;

@end
