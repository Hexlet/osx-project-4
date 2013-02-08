//
//  Cell.m
//  dna
//
//  Created by Igor Pavlov on 02.11.12.
//  Copyright (c) 2012 Igor Pavlov. All rights reserved.
//

#import "Cell.h"


@implementation Cell


+ (NSString*) getNucleotides
{
    // алфавит, составляющий ДНК
    static NSString *nucleotides = @"ATGC";
    return nucleotides;
}


- (id) init
{
    [super doesNotRecognizeSelector:_cmd];
    return nil;
}


- (id) initWithSize:(NSUInteger)size
{
    if (self = [super init])
    {
        // создать массив ДНК и зарезервировать в нем место
        NSMutableString *newDna = [NSMutableString stringWithCapacity:size];
        if (!newDna)
            return nil;

        NSString *nucleotides = [Cell getNucleotides];
        const NSUInteger nucleotideCount = [nucleotides length];

        // проинициализировать массив ДНК случайными символами нуклеотидов из заданного алфавита
        for (NSUInteger i = 0; i != size; ++i)
        {
            const NSUInteger randCharIdx = arc4random_uniform((u_int32_t)nucleotideCount);
            const unichar c = [nucleotides characterAtIndex:randCharIdx];
            [newDna appendString:[NSString stringWithCharacters:&c length:1]];
        }

        dna = newDna;
    }
    return self;
}


- (id) initWithDnaString:(NSString*)dnaStr
{
    if (!dnaStr)
        return nil;

    if (self = [super init])
    {
        NSString *nucleotides = [Cell getNucleotides];
        NSCharacterSet *invalidChars = [[NSCharacterSet characterSetWithCharactersInString:nucleotides] invertedSet];
        if (!invalidChars)
            return nil;

        dnaStr = [dnaStr uppercaseString];

        if (NSNotFound != [dnaStr rangeOfCharacterFromSet:invalidChars].location)
            return nil;

        dna = dnaStr;
    }

    return self;
}


- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:dna];
}


- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
        dna = [aDecoder decodeObject];
    return self;
}


- (NSUInteger) hammingDistance:(Cell*)otherCell
{
    // проверка на правильность аргумента
    if (!otherCell)
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Null argument" userInfo:nil];

    const NSUInteger dnaLength = [dna length];
    const NSUInteger otherDnaLength = [otherCell->dna length];

    const NSUInteger minLength = MIN(dnaLength, otherDnaLength);
    const NSUInteger maxLength = MAX(dnaLength, otherDnaLength);

    NSUInteger distance = 0;

    for (NSUInteger i = 0; i != minLength; ++i)
    {
        const unichar l = [dna characterAtIndex:i];
        const unichar r = [otherCell->dna characterAtIndex:i];
        if (l != r)
            ++distance;
    }

    distance += maxLength - minLength;
    
    return distance;
}


- (NSString*) description
{
    return dna;
}


- (id) copyWithZone:(NSZone *)zone
{
    Cell *copy = [[[self class] allocWithZone:zone] init];
    if (!copy)
        return nil;
    
    copy->dna = [dna mutableCopyWithZone:zone];
    if (!copy->dna)
        return nil;

    return copy;
}


@end
