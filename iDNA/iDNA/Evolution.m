//
//  Evolution.m
//  iDNA
//
//  Created by n on 06.01.13.
//  Copyright (c) 2013 witzawitz. All rights reserved.
//

#import "Evolution.h"

@implementation Evolution

-(id) init
{
	if (self = [super init])
	{
		step = 0;
		state = INIT;
		bestMatch = 0;
	}
	return self;
}

-(NSInteger) state	{ return state; }
-(NSInteger) step	{ return step; }

// Create goal DNA with given length.
-(Cell *) createGoalDNAWithLength:(NSInteger) length
{
	goalDNA = [[Cell alloc] initWithDNAlength:length];
	return goalDNA;
}

// Init population with given parameters.
-(void) creatPopulation
{
	population = [[NSMutableArray alloc] initWithCapacity:populationSize];
	for (NSInteger i = 0; i < populationSize; i++)
	{
		[population setObject:[[Cell alloc] initWithDNAlength:dnaLength] atIndexedSubscript:i];
	}
}

// Setters.
-(void) setMutationRate: (NSInteger) rate { mutationRate = rate; }
-(void) setPopulationSize: (NSInteger) size { populationSize = size; }
-(void) setDnaLength: (NSInteger) length { dnaLength = length; }
-(void) setState: (NSInteger) st { state = st; }
-(void) setGoalDNAwithString: (NSString *) dna
{
	[self reset];
	goalDNA = [[Cell alloc] initWithString:dna];
	dnaLength = [goalDNA DNAsize];
}

// Initialization with parameters.
-(void) initWithMutationRate:(NSInteger)rate PopulationSize: (NSInteger) size DnaLength: (NSInteger) length
{
	[self setMutationRate:rate];
	[self setPopulationSize:size];
	[self setDnaLength:length];
	
	if (state == INIT)
	{
		[self creatPopulation];
		state = STARTED;
	}
}

// Performs one step of evolution.
-(void) perfomStep
{
	step++;
	[self sortPopulation];
	if ([self isZeroHammingDistance])
	{
		state = FINISHED;
		return;
	}
	
	[self crossPopulation];
	[self mutatePopulation];
}

// Sort population by hamming distance.
- (void) sortPopulation
{
	NSArray *sorted = [population sortedArrayUsingComparator:^NSComparisonResult (id a, id b){
		NSNumber *first = [NSNumber numberWithInt:[(Cell *)a hammingDistance:goalDNA]];
		NSNumber *second = [NSNumber numberWithInt:[(Cell *)b hammingDistance:goalDNA]];
		return first > second;
	}];
	population = [NSMutableArray arrayWithArray:sorted];
}

// Cross first half of population and replace the second.
- (void) crossPopulation
{
	for (NSInteger i = ceil([population count] / 2); i < [population count]; i++)
	{
		[population setObject:[self crossDNAfromTop] atIndexedSubscript:i];
	}
}

// Crosses two random DNA from first half.
- (Cell *) crossDNAfromTop
{
	int half = ceil([population count] / 2);
	Cell *cell1 = [population objectAtIndex:arc4random_uniform(half)];
	Cell *cell2 = [population objectAtIndex:arc4random_uniform(half)];
	
	return [cell1 crossWithCell:cell2];
}

// Mutate the whole population.
- (void) mutatePopulation
{
	for (Cell *cell in population)
		[cell mutate:mutationRate];
}

// Checks whether there is cell with hamming distance = 0.
// Implying the population array is sorted.
- (Boolean) isZeroHammingDistance
{
	if ([population count] < 1)
		return NO;
	if ([goalDNA hammingDistance:[population objectAtIndex:0]] == 0)
		return YES;
	return NO;
}

-(NSInteger) bestMatch
{
	NSInteger bestHD = 0;
	if ([population count] > 0)
		bestHD = [goalDNA hammingDistance:[population objectAtIndex:0]];
	bestMatch = MAX(bestMatch, 100 - 100 * bestHD / dnaLength);
	
	return bestMatch;
}

-(void) reset
{
	state = INIT;
	step = 0;
	bestMatch = 0;
}

@end
