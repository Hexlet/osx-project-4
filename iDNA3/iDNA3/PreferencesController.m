//
//  PreferencesController.m
//  iDNA3
//

#import "PreferencesController.h"

@interface PreferencesController ()

@end

@implementation PreferencesController

+ (void)initialize
{
    NSMutableDictionary *defaultsValues = [NSMutableDictionary dictionary];
    NSInteger rate = 20;
    NSInteger population = 4000;
    NSString *DNA = @"CCAGTCCCGCTGGCATTAATCCATACCGTACCAAAGTTCCCATGGCATTGCGCGCGGACACTGAATACCTGGGCGCTGTAGTTGCTGGACCTTCGTTGTT";
    
    [defaultsValues setObject:DNA forKey:iDNAstring];
    [defaultsValues setObject:[NSNumber numberWithInteger:rate] forKey:iDNARate];
    [defaultsValues setObject:[NSNumber numberWithInteger:population] forKey:iDNAPopulation];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsValues];
}

+ (NSString *)preferencesDNAString
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:iDNAstring];
}

+ (void)setPreferencesDNAString:(NSString *)string
{
    [[NSUserDefaults standardUserDefaults] setObject:string forKey:iDNAstring];
}

+ (NSInteger)preferencesMutateRate
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:iDNARate] integerValue];
}

+ (void)setPreferencesMutateRate:(NSInteger)rate
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:rate] forKey:iDNARate];
}

+ (NSInteger)preferencesPopulationSize
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:iDNAPopulation] integerValue];
}

+ (void)setPreferencesPopulationSize:(NSInteger)size
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:size] forKey:iDNAPopulation];
}

- (id)initWithWindow:(NSWindow *)window
{
    if (self = [super initWithWindow:window])
    {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
