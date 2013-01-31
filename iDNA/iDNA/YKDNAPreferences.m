//
//  YKDNAPreferences.m
//  iDNA
//
//  Created by Yuri Kirghisov on 16.01.13.
//  Copyright (c) 2013 Yuri Kirghisov. All rights reserved.
//


#import "YKDNAPreferences.h"

static YKDNAPreferences *_sharedPreferences = nil;

#define YK_PREFERENCES_POPULATION_SIZE_KEY @"Population Size"
#define YK_PREFERENCES_DNA_LENGTH_KEY @"DNA Length"
#define YK_PREFERENCES_MUTATION_RATE_KEY @"Mutation Rate"

@implementation YKDNAPreferences

+ (YKDNAPreferences *)sharedPreferences
{
    if (!_sharedPreferences) {
        _sharedPreferences = [[YKDNAPreferences alloc] init];
    }

    return _sharedPreferences;
}

- (YKDNAPreferences *) init
{
    if (self = [super init]) {
        // Initialize factory defaults
        NSMutableDictionary *factoryDefaultsDict = [NSMutableDictionary dictionary];
        [factoryDefaultsDict setValue:[NSNumber numberWithUnsignedInteger:DEFAULT_POPULATION_SIZE] forKey:YK_PREFERENCES_POPULATION_SIZE_KEY];
        [factoryDefaultsDict setValue:[NSNumber numberWithUnsignedInteger:DEFAULT_DNA_LENGTH] forKey:YK_PREFERENCES_DNA_LENGTH_KEY];
        [factoryDefaultsDict setValue:[NSNumber numberWithUnsignedInteger:DEFAULT_MUTATION_RATE] forKey:YK_PREFERENCES_MUTATION_RATE_KEY];
        
        // Register factory defaults
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults registerDefaults:factoryDefaultsDict];
        
        // Initialize preferences from defaults
//        self.populationSize = [userDefaults integerForKey:YK_PREFERENCES_POPULATION_SIZE_KEY];
//        self.dnaLength = [userDefaults integerForKey:YK_PREFERENCES_DNA_LENGTH_KEY];
//        self.mutationRate = [userDefaults integerForKey:YK_PREFERENCES_MUTATION_RATE_KEY];
        
        // Start observing preference changes
//        [self addObserver:self forKeyPath:@"populationSize" options:0 context:@"populationSize"];
//        [self addObserver:self forKeyPath:@"dnaLength" options:0 context:@"dnaLength"];
//        [self addObserver:self forKeyPath:@"mutationRate" options:0 context:@"mutationRate"];
    }

    return self;
}

/*
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"populationSize"];
    [self removeObserver:self forKeyPath:@"dnaLength"];
    [self removeObserver:self forKeyPath:@"mutationRate"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self) {
        if ([keyPath isEqualToString:@"populationSize"]) {
            [NSUserDefaults standardUserDefaults];
        } else if ([keyPath isEqualToString:@"populationSize"]) {
            
        } else if ([keyPath isEqualToString:@"populationSize"]) {
            
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
*/

- (NSUInteger)populationSize
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:YK_PREFERENCES_POPULATION_SIZE_KEY];
}

- (void)setPopulationSize:(NSUInteger)populationSize
{
    [[NSUserDefaults standardUserDefaults] setInteger:populationSize forKey:YK_PREFERENCES_POPULATION_SIZE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger)dnaLength
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:YK_PREFERENCES_DNA_LENGTH_KEY];
}

- (void)setDnaLength:(NSUInteger)dnaLength
{
    [[NSUserDefaults standardUserDefaults] setInteger:dnaLength forKey:YK_PREFERENCES_DNA_LENGTH_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSUInteger)mutationRate
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:YK_PREFERENCES_MUTATION_RATE_KEY];
}

- (void)setMutationRate:(NSUInteger)mutationRate
{
    [[NSUserDefaults standardUserDefaults] setInteger:mutationRate forKey:YK_PREFERENCES_MUTATION_RATE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
