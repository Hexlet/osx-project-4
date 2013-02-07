//
//  Evolution.h
//  iDNA
//
//  Created by n on 06.01.13.
//  Copyright (c) 2013 witzawitz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cell.h"

// States of evolution process.
#define INIT		0
#define STARTED		1
#define FINISHED	2
#define PAUSED		3

@interface Evolution : NSObject
{
	NSInteger step;
	NSInteger state;
	
	NSInteger mutationRate;
	NSInteger populationSize;
	NSInteger dnaLength;
	
	NSInteger bestMatch;

	NSMutableArray *population;
	Cell *goalDNA;
}

-(Cell *) createGoalDNAWithLength:(NSInteger) length;
-(void) initWithMutationRate:(NSInteger)rate PopulationSize: (NSInteger) size DnaLength: (NSInteger) length;
-(void) perfomStep;
-(NSInteger) state;
-(NSInteger) step;
-(NSInteger) bestMatch;
-(void) reset;
-(void) setState: (NSInteger) st;
-(void) setGoalDNAwithString: (NSString *) dna;

@end
