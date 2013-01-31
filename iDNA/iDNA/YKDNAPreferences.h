//
//  YKDNAPreferences.h
//  iDNA
//
//  Created by Yuri Kirghisov on 16.01.13.
//  Copyright (c) 2013 Yuri Kirghisov. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_POPULATION_SIZE 20
#define DEFAULT_DNA_LENGTH 30
#define DEFAULT_MUTATION_RATE 13

@interface YKDNAPreferences : NSObject

@property NSUInteger populationSize;
@property NSUInteger dnaLength;
@property NSUInteger mutationRate;

+ (YKDNAPreferences *)sharedPreferences;

@end
