//
//  Population.m
//  iDNA
//
//  Created by alex on 12/20/12.
//  Copyright (c) 2012 alex. All rights reserved.
//

#import "Population.h"
#import "Cell.h"

@implementation Population

-(id)init
{
    if (self = [super init]) {
        elements = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id)initPopulationWithSize:(NSInteger)populationSize andSizeDNA:(NSInteger)sizeDNA andGoalDNA:(Cell *)goalDNA
{
    if (self = [self init]) {
        _goalDNA = goalDNA;
        for (int i = 0; i < populationSize; i++) {
            [elements addObject:[[Cell alloc] initWithSize:sizeDNA andRootCell:_goalDNA]];
        }
    }
    return self;
}

-(int)evolution:(NSInteger)mutation
{
    [elements sortUsingSelector:@selector(compareWithCell:)];
    /*
    for (Cell* cell in elements) {
        NSLog(@"%d", [cell hammingDistance:_goalDNA]);
    }
     */

    int result = [[elements objectAtIndex:0] hammingDistance:_goalDNA];
    
    _bestMatch = [elements objectAtIndex:0];
    
    // ищем половину списка
    int size = (int)elements.count/2;
    int middle = size; // запомним реальную половину списка
    
    // нам проще скрестить четное кол-во элементов, пусть один остается неизменным
    if (size % 2) {
        size--;
    }
    
    int i = 0;
    while (i < size/2) {
        Cell *cell1 = [elements objectAtIndex:i];
        Cell *cell2 = [elements objectAtIndex:size-(i+1)]; // - второй берем с обратной стороны
        
        // комбинируем, выбирая случайный способ (1, 2 или 3)
        Cell *newCell = [cell1 combineWith:cell2 withWay:(1+arc4random()%3)];
        
        // замещаем вторую половину наших элементов на свежескомбинированные элементы
        [elements replaceObjectAtIndex:middle+i withObject:newCell];
        i++;
    }
    
    for (Cell *cell in elements) {
        [cell mutate:mutation];
    }
    
    return result;
}

-(NSMutableArray*)getElements
{
    return elements;
}

@end
