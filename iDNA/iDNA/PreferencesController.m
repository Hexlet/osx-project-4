//
//  PreferencesController.m
//  iDNA
//
//  Created by alex on 01/02/2013.
//  Copyright (c) 2013 alex. All rights reserved.
//

#import "PreferencesController.h"

extern NSString *const PrefPopulationSize = @"PrefPopulationSize";
extern NSString *const PrefDNALength = @"PrefDNALength";
extern NSString *const PrefMutationRate = @"PrefMutationRate";


@implementation PreferencesController

-(id)init
{
    if (self = [super init]) {
        NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
        
        // -1 означает, что нужно взять случайное значение
        [defaultValues setObject:[NSNumber numberWithInt:-1] forKey:PrefPopulationSize];
        [defaultValues setObject:[NSNumber numberWithInt:-1] forKey:PrefDNALength];
        [defaultValues setObject:[NSNumber numberWithInt:-1] forKey:PrefMutationRate];
        
        [[NSUserDefaults standardUserDefaults]registerDefaults:defaultValues];
    }
    return self;
}

-(void)setPopulationSize:(NSInteger)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:PrefPopulationSize];
}
-(void)setDNALength:(NSInteger)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:PrefDNALength];
}
-(void)setMutationRate:(NSInteger)value
{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:PrefMutationRate];
}

-(NSInteger)populationSize
{
    NSInteger result = [[NSUserDefaults standardUserDefaults] integerForKey:PrefPopulationSize];
    return result < 0? 1+arc4random()%100 : result;
}
-(NSInteger)DNALength
{
    NSInteger result = [[NSUserDefaults standardUserDefaults] integerForKey:PrefDNALength];
    return result < 0? 1+arc4random()%100 : result;
}
-(NSInteger)mutationRate
{
    NSInteger result = [[NSUserDefaults standardUserDefaults] integerForKey:PrefMutationRate];
    return result < 0? 1+arc4random()%100 : result;
}


@end
