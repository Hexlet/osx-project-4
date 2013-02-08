//
//  Cell+mutator.m
//  dna
//
//  Created by Igor Pavlov on 03.11.12.
//  Copyright (c) 2012 Igor Pavlov. All rights reserved.
//

#import "Cell+hybrid.h"


@implementation Cell (hybrid)


+ (Cell*) makeHybrid0With:(Cell*)a andWith:(Cell*)b
{
    const NSUInteger dnaLength = [a->dna length];

    NSMutableString *newDna = [NSMutableString stringWithCapacity:dnaLength];

    [newDna appendString:[a->dna substringToIndex:dnaLength/2]];
    [newDna appendString:[b->dna substringFromIndex:dnaLength/2]];

    return [[Cell alloc] initWithDnaString:newDna];
}


+ (Cell*) makeHybrid1With:(Cell*)a andWith:(Cell*)b
{
    const NSUInteger dnaLength = [a->dna length];

    NSMutableString *newDna = [NSMutableString stringWithCapacity:dnaLength];

    for (NSUInteger i = 0; i != dnaLength; ++i)
    {
        const NSUInteger curPercent = 100*i/(dnaLength - 1);
        if (curPercent & 1)
            [newDna appendString:[b->dna substringWithRange:NSMakeRange(i, 1)]];
        else
            [newDna appendString:[a->dna substringWithRange:NSMakeRange(i, 1)]];
    }

    return [[Cell alloc] initWithDnaString:newDna];
}


+ (Cell*) makeHybrid2With:(Cell*)a andWith:(Cell*)b
{
    const NSUInteger dnaLength = [a->dna length];

    NSMutableString *newDna = [NSMutableString stringWithCapacity:dnaLength];

    const NSUInteger i0 = 20*dnaLength/100;
    const NSUInteger l1 = 60*dnaLength/100;
    const NSUInteger i2 = i0 + l1;

    [newDna appendString:[a->dna substringToIndex:i0]];
    [newDna appendString:[b->dna substringWithRange:NSMakeRange(i0, l1)]];
    [newDna appendString:[a->dna substringFromIndex:i2]];

    return [[Cell alloc] initWithDnaString:newDna];
}


+ (Cell*) makeHybrid3With:(Cell*)a andWith:(Cell*)b
{
    const NSUInteger dnaLength = [a->dna length];

    NSMutableString *newDna = [NSMutableString stringWithCapacity:dnaLength];

    for (NSUInteger i = 0; i != dnaLength; ++i)
    {
        if (i & 1)
            [newDna appendString:[b->dna substringWithRange:NSMakeRange(i, 1)]];
        else
            [newDna appendString:[a->dna substringWithRange:NSMakeRange(i, 1)]];
    }

    return [[Cell alloc] initWithDnaString:newDna];
}


+ (Cell*) makeHybridWith:(Cell*)a andWith:(Cell*)b
{
    if (!a  ||  !b)
        return nil;

    if ([a->dna length] != [b->dna length])
        return nil;

    const NSUInteger method = arc4random_uniform(4);
    switch (method)
    {
        case 0:
            return [Cell makeHybrid0With:a andWith:b];

        case 1:
            return [Cell makeHybrid1With:a andWith:b];

        case 2:
            return [Cell makeHybrid2With:a andWith:b];

        case 3:
            return [Cell makeHybrid3With:a andWith:b];
    }

    return nil;
}

@end
