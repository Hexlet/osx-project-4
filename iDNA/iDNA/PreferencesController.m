//
//  PreferencesController.m
//  iDNA
//
//  Created by Admin on 04.02.13.
//  Copyright (c) 2013 Kabest. All rights reserved.
//

#import "PreferencesController.h"

NSString *const IDNAPopulationSize = @"IDNAPopulationSize";
NSString *const IDNADNALength = @"IDNADNALength";
NSString *const IDNAMutationRate = @"IDNAMutationRate";

@implementation PreferencesController

-(id)init {
    self = [super init];
    if (self) {
        NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
        [defaults setObject:[NSNumber numberWithInt:0] forKey:IDNAPopulationSize];
        [defaults setObject:[NSNumber numberWithInt:0] forKey:IDNADNALength];
        [defaults setObject:[NSNumber numberWithInt:0] forKey:IDNAMutationRate];
    }
    return self;
}

-(void)setPopulationSize:(NSInteger)value {
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:IDNAPopulationSize];
}

-(void)setDNALength:(NSInteger)value {
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:IDNADNALength];
}

-(void)setMutationRate:(NSInteger)value {
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:IDNAMutationRate];
}

-(NSInteger)populationSize {
    NSInteger res = [[NSUserDefaults standardUserDefaults] integerForKey:IDNAPopulationSize];
    if (res == 0)
        return 3400;
    else
        return res;
}

-(NSInteger)DNALength {
    NSInteger res = [[NSUserDefaults standardUserDefaults] integerForKey:IDNADNALength];
    if (res == 0)
        return 42;
    else
        return res;
}

-(NSInteger)mutationRate {
    NSInteger res = [[NSUserDefaults standardUserDefaults] integerForKey:IDNAMutationRate];
    if (res == 0)
        return 13;
    else
        return res;
}

@end
