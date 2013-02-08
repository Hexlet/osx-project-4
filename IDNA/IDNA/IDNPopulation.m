//
//  IDNPopulation.m
//  IDNA
//
//  Created by Dmitriy Zhukov on 07.01.13.
//  Copyright (c) 2013 Dmitriy Zhukov. All rights reserved.
//

#import "IDNPopulation.h"
#import "IDNCell.h"

@implementation IDNPopulation

- (id)init {
    self= [super init];
    if (self) {
        self.population = [[NSMutableArray alloc]init];
        self.generationNumber = 0;
        self.bestDNADistanseInPopulation = 0;
        self.progressToTarget = 0;
        self.populationRandomNumber = 0;
    }
    return self;
}

- (void)createPopulationWithCount:(NSInteger)aPopulation andDNALength:(NSInteger)aDNALenght {
    
    for (int i = 0; i < aPopulation; i++) {
        IDNCell* unicDNA = [[IDNCell alloc]initWithRandom:self.populationRandomNumber];
        [unicDNA fillDNAArrayWithCapacity:aDNALenght];
        [self.population addObject:unicDNA];
    }
    
}

- (void)sortPopulationByHummingDistanceTo:(IDNCell*)aGoalDNA {
    
    //проставляем хамминг дистанс
    for (IDNCell *uDNA in self.population) {
        uDNA.unitDistanceToTargetDNA = [aGoalDNA hammingDistance:uDNA];
    }
    
    //Сортируем массив по хамминг дистанс
    self.population = [NSMutableArray arrayWithArray: [self.population sortedArrayUsingComparator: ^(IDNCell* obj1, IDNCell* obj2) {
        
        NSInteger a = [obj1 unitDistanceToTargetDNA];
        NSInteger b = [obj2 unitDistanceToTargetDNA];
        
        if (a > b) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (b < a) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }]];
    
    //Выбираем лучшее значение
    self.bestDNADistanseInPopulation = [[self.population objectAtIndex:0] unitDistanceToTargetDNA];
    
    float a = 100.0-((([[self.population objectAtIndex:0] unitDistanceToTargetDNA]*1.0)/([aGoalDNA.DNA count]*1.0))*100);
    self.progressToTarget = ceil(a);
}

- (void) crossingBestDNA {
    //Выборка 50% массива.
    
    srandom (self.populationRandomNumber); //установка настроек рандома
    
    float a = ([self.population count]*50.0)/100.0;
    NSInteger numberOfBestCells = ceil(a); //первые 50 % ячеек
    NSInteger numberOfLastCells = ([self.population count]-numberOfBestCells); //это те ячейки которые нужно заменить
    
    //Создаем массив с изменениями днк для худших особей
    NSMutableArray *crossDNA = [[NSMutableArray alloc]initWithCapacity:numberOfLastCells];
    
    for (int i = 0 ; i < numberOfLastCells; i++) { //прогоняем алгоритм столько раз, сколько ячеек нужно заменить
        
        //Генерируем два случайных неодинаковых индекса в интервале от 0 до numberOfBestCells
        
        NSInteger indexM = arc4random ()%numberOfBestCells;
        NSInteger indexF;
        
        for(;;){
            indexF = arc4random ()%numberOfBestCells;
            if (indexF != indexM) {
                break;
            }}
        
        //Выбор одного из трех алгоритмoв скрещивания
        switch (arc4random ()%3) {
                
            case 0:
                [crossDNA addObject:[self halfByHalfCrossing:[_population objectAtIndex:indexM]with:[_population objectAtIndex:indexF]]];
                break;
            case 1:
                [crossDNA addObject:[self oneByOneCrossing:[_population objectAtIndex:indexM]with:[_population objectAtIndex:indexF]]];
                break;
            case 2:
                [crossDNA addObject:[self partsCrossing:[_population objectAtIndex:indexM]with:[_population objectAtIndex:indexF]]];
                break;
        }
    }
    for(NSInteger i = numberOfBestCells; i < [_population count]; i++) {
        NSInteger crossIndex = i-numberOfBestCells;
        [self.population replaceObjectAtIndex:i withObject:[crossDNA objectAtIndex:crossIndex]];
    }
}

- (IDNCell*)halfByHalfCrossing:(IDNCell*)firstCell with:(IDNCell*)secondCell {
    
    NSInteger DNALengthInPopulation = [[firstCell valueForKey:@"DNA"]count];
    IDNCell* unDNA = [[IDNCell alloc]initWithRandom:self.populationRandomNumber];
    
    float a = DNALengthInPopulation/2.0;
    NSInteger n1 = ceil(a);
    NSInteger n2 = (DNALengthInPopulation-n1);
    
    for (int i = 0 ; i < n1; i++) {
        [unDNA.DNA addObject:[firstCell.DNA objectAtIndex:i]];
    }
    for (int i = 0 ; i < n2; i++) {
        [unDNA.DNA addObject:[secondCell.DNA objectAtIndex:i]];
    }
    return unDNA;
}

- (IDNCell*)oneByOneCrossing:(IDNCell*)firstCell with:(IDNCell*)secondCell {
    NSInteger DNALengthInPopulation = [[firstCell valueForKey:@"DNA"]count];
    IDNCell* unDNA = [[IDNCell alloc]initWithRandom:self.populationRandomNumber];
    for (int i = 0 ; i < DNALengthInPopulation; i++) {
        if (i & 1) {
            [unDNA.DNA addObject:[secondCell.DNA objectAtIndex:i]];
        } else {
            [unDNA.DNA addObject:[firstCell.DNA objectAtIndex:i]];
        }
    }
    return unDNA;
}

- (IDNCell*)partsCrossing:(IDNCell*)firstCell with:(IDNCell*)secondCell {
    
    NSInteger DNALengthInPopulation = [[firstCell valueForKey:@"DNA"]count];
    IDNCell* unDNA = [[IDNCell alloc]initWithRandom:self.populationRandomNumber];
    
    float a = DNALengthInPopulation*0.4;
    NSInteger n13 = ceil(a);
    float b = n13/2.0;
    NSInteger n1 = ceil(b);
    NSInteger n2 = DNALengthInPopulation - n13;
    
    for (int i = 0 ; i < n1; i++) {
        [unDNA.DNA addObject:[firstCell.DNA objectAtIndex:i]];
    }
    for (int i = 0 ; i < n2; i++) {
        [unDNA.DNA addObject:[secondCell.DNA objectAtIndex:i]];
    }
    for (NSInteger i = n1+n2; i < DNALengthInPopulation; i++) {
        [unDNA.DNA addObject:[firstCell.DNA objectAtIndex:i]];
    }
    return unDNA;
}

- (void) populationMutate: (NSInteger)percentage {
    for (IDNCell *cell in _population) {
        [cell mutate:percentage];
    }
    self.generationNumber++;
}

@end