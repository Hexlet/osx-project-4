//
//  Cell.m
//  macosx-hw1
//
//  Created by Admin on 17.11.12.
//  Copyright (c) 2012 Kabest. All rights reserved.
//
#import <stdlib.h>
#import <time.h>
#import "Cell.h"

static NSArray *dnaChars = nil;

@implementation Cell
@synthesize dna;

+(NSArray*)dnaChars {
    if (!dnaChars)
        dnaChars = [[NSArray alloc] initWithObjects: @"A", @"T", @"G", @"C", nil];
    return dnaChars;
}

-(id)initWithCapacity:(NSInteger)val {
    self = [super init];
    capacity = [[NSNumber numberWithInteger:val]intValue];
    dna = [NSMutableArray arrayWithCapacity:capacity];
    
    srandom([[NSNumber numberWithLong:time(NULL)]intValue]);
    for (int i = 0; i < capacity; i++) {
        int r = arc4random() % 4;
        [dna addObject: [[Cell dnaChars] objectAtIndex: r]];
    }
    return self;
}

-(NSInteger)capacity {
    return capacity;
}

-(NSString*)stringValue {
    NSMutableString* res = [NSMutableString stringWithCapacity:capacity];
    for (int i = 0; i < capacity; i++) {
        [res appendString: [dna objectAtIndex:i]];
    }
    return res;
}

-(void)setStringValue:(NSString *)val {
    for (int i = 0; i < capacity; i++) {
        [dna setObject:[NSString stringWithFormat:@"%hu", [val characterAtIndex:i]] atIndexedSubscript:i];
    }
}

-(int) hammingDistance:(Cell *)cell {
    int res = 0;
    for (int i = 0; i < capacity; i++) {
        if ([dna objectAtIndex:i] != [[cell dna] objectAtIndex:i])
            res++;
    }
    return res;
}

// мутация
-(void)mutateDNA:(NSUInteger)percentage {
    if (percentage <= 100) {
        // в массиве changed будем хранить позиции мутировавших генов
        NSMutableArray* changed = [NSMutableArray arrayWithCapacity:capacity];
        int pos;
        srandom([[NSNumber numberWithLong:time(NULL)]intValue]);
        for (int i = 0; i < percentage; i++) {
            // ищем позицию еще не мутировавшего гена
            do {
                pos = arc4random() % capacity;
            } while ([changed containsObject: [NSNumber numberWithInt: pos]]);
            // выбираем случайный новый ген
            int r = arc4random() % 4;
            [changed addObject: [NSNumber numberWithInt: pos]];
            // и заменяем на него
            [self.dna replaceObjectAtIndex: i withObject: [[Cell dnaChars]objectAtIndex: r]];
        }
    }
}

// скрещивание
-(Cell*)crossBreedingWith:(Cell*)cell {
    if (cell == nil)
        return nil;
    if ([self capacity] != [cell capacity])
        return nil;
    // здесь будем хранить новую цепочку ДНК
    NSMutableString *newDNAString = [NSMutableString stringWithCapacity:[self capacity]];
    int percent;
    // тип мутации выбираем случайным образом из трех вариантов
    int r = arc4random() % 3;
    switch (r) {
        case 0: // 50% + 50%
            [newDNAString appendString:[[self stringValue]substringToIndex:[self capacity]/2]];
            [newDNAString appendString:[[cell stringValue]substringFromIndex:[cell capacity]/2]];
            break;
        case 1: // 1% + 1% + 1% ...
            // сколько генов будет в одном проценте?
            percent = [self capacity]/100;
            if (percent == 0)
                percent = 1;
            int p = 0;
            BOOL fromSelf = YES;
            while (p < [self capacity]) {
                // поочередно выбираем гены из обеих цепочек ДНК
                if (fromSelf)
                    [newDNAString appendString:[[self stringValue]substringWithRange:NSMakeRange(p,percent)]];
                else
                    [newDNAString appendString:[[self stringValue]substringWithRange:NSMakeRange(p,percent)]];
                fromSelf = !fromSelf;
                p += percent;
            }
            break;
        case 2: // 20% + 60% + 20%
            [newDNAString appendString:[[self stringValue]substringToIndex:[self capacity]/5]];
            [newDNAString appendString:[[cell stringValue]substringWithRange:NSMakeRange([cell capacity]/5, [cell capacity]*4/5)]];
            [newDNAString appendString:[[self stringValue]substringFromIndex:[self capacity]*4/5]];
            break;
        default:
            break;
    }
    // создаем и возвращаем новую ДНК
    Cell *newDNA = [[Cell alloc] initWithCapacity:[self capacity]];
    [newDNA setStringValue:newDNAString];
    return newDNA;
}

@end
