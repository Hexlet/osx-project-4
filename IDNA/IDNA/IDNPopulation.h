//
//  IDNPopulation.h
//  IDNA
//
//  Created by Dmitriy Zhukov on 07.01.13.
//  Copyright (c) 2013 Dmitriy Zhukov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IDNCell;

@interface IDNPopulation : NSObject

@property NSMutableArray* population;
@property NSInteger generationNumber;
@property NSInteger bestDNADistanseInPopulation;
@property NSInteger progressToTarget;
@property unsigned int populationRandomNumber;

- (void)createPopulationWithCount:(NSInteger)aPopulation andDNALength:(NSInteger)aDNALenght;
- (void)sortPopulationByHummingDistanceTo:(IDNCell*)aGoalDNA;
- (void)populationMutate: (NSInteger)percentage;
- (void) crossingBestDNA;
- (IDNCell*)halfByHalfCrossing:(IDNCell*)firstCell with:(IDNCell*)secondCell;
- (IDNCell*)oneByOneCrossing:(IDNCell*)firstCell with:(IDNCell*)secondCell;
- (IDNCell*)partsCrossing:(IDNCell*)firstCell with:(IDNCell*)secondCell;

@end
