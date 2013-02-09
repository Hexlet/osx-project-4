//
//  Cell.m
//  hexlet_dna
//
//  Created by Alexander Shvets on 02.11.12.
//  Copyright (c) 2012 Alexander Shvets. All rights reserved.
//

#import "Cell.h"

@implementation Cell

- (id)initWithLength:(int) dnaLength
{
    if(self = [super init]){
        _dna = [NSMutableArray arrayWithCapacity:dnaLength];
        _hammingDistance = dnaLength;
        nucleotides = [[Nucleotides sharedInstance] getNucleotides];
        
        int nucleotideIndex;
        for(int i = 0; i < dnaLength; i++){
            nucleotideIndex = random() % 4; //arc4random() % 4;
            [_dna addObject:[nucleotides objectAtIndex:nucleotideIndex]];
        }
        
    }

    return self;
}

- (id)initWithDNA:(NSArray*)dnaArr
{
    if(self = [super init]){
        _dna = [NSMutableArray arrayWithArray:dnaArr];
        _hammingDistance = (int)[dnaArr count];
        nucleotides = [[Nucleotides sharedInstance] getNucleotides];
    }
    
    return self;
}

- (id)initWithString:(NSString*)dnaString
{
    if(self = [super init]){
        _dna = [NSMutableArray arrayWithCapacity:[dnaString length]];
        for (int i=0; i < [dnaString length]; i++) {
            [_dna addObject:[NSString stringWithFormat:@"%c", [dnaString characterAtIndex:i]]];
        }
        
        _hammingDistance = (int)[dnaString length];
        nucleotides = [[Nucleotides sharedInstance] getNucleotides];
    }
    
    return self;
}

- (void) mutate:(int)percent {
    
    if(percent < 1){
        return;
    } else if(percent > 100){
        percent = 100;
    }
    
    uint indexToReplace, nucleotideIndex, indexValue;
    uint nucleotidesToReplace = (uint)(percent * 0.01 * [self.dna count]);
    
    if(nucleotidesToReplace < 1){
        // необходимо изменить минимум 1 нуклеотид
        nucleotidesToReplace = 1;
    }
    
    NSMutableArray *replacedIndexes = [NSMutableArray arrayWithCapacity:nucleotidesToReplace];
    
    // заполняем массив доступными индексами
    for (int i = 0; i < [self.dna count]; i++){
        [replacedIndexes addObject:[NSNumber numberWithUnsignedInt:i]];
    }
    
    while (nucleotidesToReplace) {
        indexToReplace = random() % (int)[replacedIndexes count]; //arc4random() % [replacedIndexes count]; // индекс для замены
        indexValue = [[replacedIndexes objectAtIndex:indexToReplace] unsignedIntValue];
        
        do { // исключаем замену на аналогичный нуклеотид
            nucleotideIndex = random() % 4; //arc4random() % 4;
        } while ([[self.dna objectAtIndex:indexValue] isEqual:[nucleotides objectAtIndex:nucleotideIndex]]);
        
        // заменяем нуклеотид по индексу indexToReplace
        [self.dna replaceObjectAtIndex:indexValue withObject:[nucleotides objectAtIndex:nucleotideIndex]];
        
        [replacedIndexes removeObjectAtIndex:indexToReplace]; // изымаем этот индекс из списка доступных
        
        nucleotidesToReplace--;
    }
    
}

- (int)hammingDistance: (Cell*)goalDNA {
    int distance = 0;
    for(int i = 0; i < [goalDNA.dna count]; i++){
        if(![[goalDNA.dna objectAtIndex:i] isEqualToString:[self.dna objectAtIndex:i]]) distance++;
    }
    
    self.hammingDistance = distance;
    
    return distance;
}

- (NSString*)stringValue
{
    return [self.dna componentsJoinedByString:@""];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"HD: %d | DNA: %@", self.hammingDistance, [self.dna componentsJoinedByString:@""]];
}

@end
