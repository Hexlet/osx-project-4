//
//  Population.h
//  iDNA
//
//  Created by alex on 12/20/12.
//  Copyright (c) 2012 alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Cell;

@interface Population : NSObject {
    NSMutableArray *elements;
}

@property Cell *goalDNA;
@property Cell *bestMatch; // для отладки

-(id)initPopulationWithSize:(NSInteger)populationSize andSizeDNA:(NSInteger)sizeDNA andGoalDNA:(Cell*)goalDNA;
-(int)evolution: (NSInteger)mutation;

-(NSMutableArray*)getElements;

@end
