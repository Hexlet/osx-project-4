//
//  Population.h
//  iDNA
//
//  Created by Alexander Shvets on 24.12.12.
//  Copyright (c) 2012 Alexander Shvets. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cell.h"

@interface Population : NSObject

@property NSMutableArray* cells;

- (id)initWithPopulationSize:(int)size andDNALength:(int)dnaLength;

- (void)hammingDistanceWith:(Cell*)goalDNA;

- (void)sort;

- (BOOL)evolutionSuccess;

- (void)hybridize;

- (void)mutate:(int)percent;

@end
