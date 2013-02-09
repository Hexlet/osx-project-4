//
//  Population.m
//  iDNA
//
//  Created by Alexander Shvets on 24.12.12.
//  Copyright (c) 2012 Alexander Shvets. All rights reserved.
//

#import "Population.h"

@implementation Population

- (id)initWithPopulationSize:(int)size andDNALength:(int)dnaLength
{
    if(self = [super init]){
        _cells = [NSMutableArray arrayWithCapacity:size];
        
        for(int i = 0; i < size; i++){
            [_cells addObject:[[Cell alloc] initWithLength:dnaLength]];
        }
    }
    
    return self;
}


// обновляем расстояние Хэмминга для популяции
- (void)hammingDistanceWith:(Cell*)goalDNA
{
    for(Cell* cell in self.cells){
        [cell hammingDistance:goalDNA];
    }
}


// сортировка поплуляции на основе расстояния Хэмминга
- (void)sort
{
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"hammingDistance" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedCells = [self.cells sortedArrayUsingDescriptors:sortDescriptors];
    
    self.cells = [NSMutableArray arrayWithArray:sortedCells];
}


// проверка нет ли полного совпадения с целевой ДНК 
- (BOOL)evolutionSuccess
{
    BOOL result = NO;
    
    NSIndexSet* foundIndexes = [self.cells indexesOfObjectsPassingTest: ^ BOOL(Cell* cell, NSUInteger idx, BOOL *stop){
        if(cell.hammingDistance == 0) return YES;
        return NO;
    }];
    
    if([foundIndexes count]) result = YES;
    
    return result;
}


// скрестить кандидатов из топ 50% и заменить результатом оставшиеся 50%
- (void) hybridize
{
    int populationSize = (int)[self.cells count];
    int halfPopulation = populationSize / 2;
    
    NSArray* topCells = [self.cells subarrayWithRange:NSMakeRange(0, halfPopulation + (populationSize % halfPopulation))];
    NSMutableArray* newCells = [NSMutableArray arrayWithCapacity:halfPopulation];
    
    for(int i = 0; i < halfPopulation; i++){
        
        // случайно выбираем две клетки для скрещивания
        NSArray* firstDNA = [[topCells objectAtIndex:(arc4random() % [topCells count])] dna];
        NSArray* secondDNA = [[topCells objectAtIndex:(arc4random() % [topCells count])] dna];
        
        int DNALength = (int)[firstDNA count];
        NSMutableArray* newDNA = [NSMutableArray arrayWithCapacity:DNALength];
        
        // выбор случайного алгоритма скрещивания
        switch(random() % 3 /*arc4random() % 3*/){
            case 0: // 50% первого ДНК + 50% второго ДНК
            {
                int halfDNALenth = DNALength / 2;
                
                NSArray* subDNA1 = [firstDNA subarrayWithRange:NSMakeRange(0, halfDNALenth + (DNALength % halfDNALenth))];
                NSArray* subDNA2 = [firstDNA subarrayWithRange:NSMakeRange(halfDNALenth + (DNALength % halfDNALenth), halfDNALenth)];
                
                [newDNA addObjectsFromArray:subDNA1];
                [newDNA addObjectsFromArray:subDNA2];
                
                break;
            }
                
            case 1: // 1% первого ДНК + 1% второго ДНК + 1% первого ДНК + ... и т.д.
            {
                for(int f = 0; f < DNALength; f+=2){
                    [newDNA addObject:[firstDNA objectAtIndex:f]];
                    if(f+1 < DNALength) [newDNA addObject:[secondDNA objectAtIndex:f+1]];
                }
                
                break;
            }
                
            case 2:
            default: // 20% первого ДНК + 60% второго ДНК + 20% первого ДНК
            {
                int perc20 = DNALength * 0.2;
                int perc60 = DNALength - perc20 * 2;
                
                NSArray* subDNA1 = [firstDNA subarrayWithRange:NSMakeRange(0, perc20)];
                NSArray* subDNA2 = [secondDNA subarrayWithRange:NSMakeRange(perc20, perc60)];
                NSArray* subDNA3 = [firstDNA subarrayWithRange:NSMakeRange(perc20 + perc60, perc20)];
                
                [newDNA addObjectsFromArray:subDNA1];
                [newDNA addObjectsFromArray:subDNA2];
                [newDNA addObjectsFromArray:subDNA3];
                
                break;
            }
        }
        
        Cell* newCell = [[Cell alloc] initWithDNA:newDNA];
        [newCells addObject:newCell];
    }
    
    // замена результатом скрещивания оставшиеся 50%
    NSMutableArray *newGeneration = [NSMutableArray arrayWithArray:topCells];
    [newGeneration addObjectsFromArray:newCells];
    self.cells = newGeneration;
}


// матация популяции
- (void)mutate:(int)percent
{
    for(Cell* cell in self.cells){
        [cell mutate:percent];
    }
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Population: %@", self.cells];
}

@end