//
//  YKDNA.m
//  iDNA
//
//  Created by Yuri Kirghisov on 17.12.12.
//  Copyright (c) 2012 Yuri Kirghisov. All rights reserved.
//

#import "YKDNA.h"
#include <stdlib.h>

static NSArray* dnaLetters = nil;

@implementation YKDNA

+ (NSArray *)dnaLetters
{
    if (!dnaLetters) {
        dnaLetters = @[@"A", @"C", @"G", @"T"];
    }
    
    return dnaLetters;
}

- (YKDNA *)initWithLength:(NSUInteger)length
{
    if (self = [super init]) {
//        dnaLetters = [NSArray arrayWithObjects:@"A", @"C", @"G", @"T", nil];

        NSMutableString *newDNA = [NSMutableString string];
        for (NSUInteger i=0; i<length; i++) {
            [newDNA appendString:[[YKDNA dnaLetters] objectAtIndex:arc4random_uniform((unsigned int)[dnaLetters count])]];
        }

        self.dnaString = [NSString stringWithString:newDNA];
    }
    
    return self;
}

- (NSInteger)hammingDistanceToDNA:(YKDNA *)aDNA
{
    if (!aDNA)
        return -1;

    if (aDNA.dnaString.length != self.dnaString.length) {
        NSLog (@"Trying to determine hamming distance between DNAs of different length (%lu and %lu)",
               self.dnaString.length, aDNA.dnaString.length);
        return -1;
    }

    // Вычисление hamming distance
    NSUInteger hammingDistance = 0;
    for (NSUInteger i=0; i<self.dnaString.length; i++) {
        if ([self.dnaString characterAtIndex:i] != [aDNA.dnaString characterAtIndex:i])
            hammingDistance++;
    }
    
    return hammingDistance;
}

- (void)mutateWithPercentage:(NSUInteger)percentage
{
    if (percentage > 100) {
        // Неверное значение.
        NSLog (@"Trying to mutate %lu percents, no luck", percentage);
        return;
    }
    
    // Определяем кол-во мутирующих генов
    NSUInteger dnaLength = self.dnaString.length;
    NSInteger genesToMutate = percentage * dnaLength / 100;
    
    // Строим два массива - индексы немутирующих генов (все индексы) и мутирующих (сначала пуст)
    NSMutableArray *outstandingIndexes = [NSMutableArray arrayWithCapacity:dnaLength];
    NSMutableArray *mutatingIndexes = [NSMutableArray arrayWithCapacity:dnaLength];
    for (NSUInteger index = 0; index < dnaLength; index++)
        [outstandingIndexes addObject:[NSNumber numberWithUnsignedInteger:index]];
    
    // И в случайном порядке переносим genesToMutate индексов из первого массива во второй
    for (NSInteger i = 0; i < genesToMutate; i++) {
        int r = arc4random_uniform((u_int32_t)outstandingIndexes.count);
        NSNumber *index = outstandingIndexes[r];
        [mutatingIndexes addObject:index];
        [outstandingIndexes removeObject:index];
    }
    
    // Теперь для мутирующих генов подбираем случайное новое значение, не совпадающее с текущим
    NSMutableString *newDNAString = [NSMutableString stringWithString:self.dnaString];
    for (NSInteger i=0; i<mutatingIndexes.count; i++) {
        NSUInteger index = [mutatingIndexes[i] unsignedIntegerValue];
        NSString *place = [self.dnaString substringWithRange:NSMakeRange(index, 1)];
        NSMutableArray *genesToSelect = [NSMutableArray arrayWithArray:[YKDNA dnaLetters]];
        [genesToSelect removeObject:place];
        NSString *newValue = genesToSelect[arc4random_uniform(genesToSelect.count)];
        [newDNAString replaceCharactersInRange:NSMakeRange(index, 1) withString:newValue];
    }

    self.dnaString = [NSString stringWithString:newDNAString];
}

- (YKDNA *)dnaByBreedingWithDNA:(YKDNA *)aDNA
{
    if (!aDNA)
        return nil;

    if (aDNA.dnaString.length != self.dnaString.length) {
        NSLog (@"Trying to breed DNAs of different length (%lu and %lu)", self.dnaString.length, aDNA.dnaString.length);
        return nil;
    }

    NSMutableString *newDNAString = [NSMutableString stringWithCapacity:self.dnaString.length];
    
    BOOL ticker;
    int r = arc4random_uniform(3);
    switch (r) {
        case 0:
            // 50% первого ДНК + 50% второго ДНК
            [newDNAString appendString:[self.dnaString substringToIndex:self.dnaString.length/2]];
            [newDNAString appendString:[aDNA.dnaString substringFromIndex:self.dnaString.length/2]];
            break;
        case 1:
            // 1% первого ДНК + 1% второго ДНК + 1% первого ДНК + ... и т.д.
            ticker = YES;
            for (NSUInteger i=0; i<self.dnaString.length; i++) {
                if (ticker) {
                    [newDNAString appendString:[self.dnaString substringWithRange:NSMakeRange(i, 1)]];
                } else {
                    [newDNAString appendString:[aDNA.dnaString substringWithRange:NSMakeRange(i, 1)]];
                }
                ticker = !ticker;
            }
            break;
        default:
            // 20% первого ДНК + 60% второго ДНК + 20% первого ДНК
            [newDNAString appendString:[self.dnaString substringToIndex:self.dnaString.length/5]];
            [newDNAString appendString:[aDNA.dnaString substringWithRange:
                                NSMakeRange(self.dnaString.length/5, self.dnaString.length*4/5-self.dnaString.length/5)]];
            [newDNAString appendString:[self.dnaString substringFromIndex:self.dnaString.length*4/5]];
            break;
    }

    YKDNA *targetDNA = [[YKDNA alloc] initWithLength:self.dnaString.length];
    targetDNA.dnaString = [NSString stringWithString:newDNAString];
    return targetDNA;
}

@end
