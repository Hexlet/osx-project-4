//
//  Population.m
//  iDNA
//
//  Created by Роман Евсеев on 06.01.13.
//  Copyright (c) 2013 Роман Евсеев. All rights reserved.
//

#import "Population.h"

@implementation Population

-(id)initWithCapacity:(NSUInteger)capacity DNALength:(NSUInteger)len {
    Cell * cell;
    if (self = [super init]) {
        _step = 0;
        _count = 0;
        _mutationRate = 10;
        _cells = [[NSMutableArray alloc] initWithCapacity:capacity];
        _goalDNA = [[Cell alloc] initWithCapacity:len];
        for (int i = 0; i<capacity; i++) {
            cell = [[Cell alloc] initWithCapacity:len];
            [cell hammingDistance:_goalDNA];
            [_cells addObject: cell];
            _count++;
        }
    }
    return self;
}

-(BOOL)evolution {
    Cell * cell;
    _step++;
    [_cells sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber * first = [NSNumber numberWithUnsignedInteger:[(Cell *)obj1 lastDistance]];
        NSNumber * second = [NSNumber numberWithUnsignedInteger:[(Cell *)obj2 lastDistance]];
        return [first compare:second];
    }];
    
    _bestMatch = [[_cells objectAtIndex:0] hammingDistance:_goalDNA];
    if (_bestMatch!=0) {
        for (int i=_count / 2; i<_count; i++) {
            Cell * cellOne = [_cells objectAtIndex:arc4random() % (_count / 2)];
            Cell * cellTwo = [_cells objectAtIndex:arc4random() % (_count / 2)];
            cell = [Cell cellWithString:[Cell mixString:[cellOne description] withString:[cellTwo description]]];
            [cell hammingDistance:_goalDNA];
            [_cells replaceObjectAtIndex:i withObject:
                cell];
        }
//        NSString * s = @"Hamms: ";
        for (int i=0; i<_count; i++) {
//            s = [s stringByAppendingFormat:@"\n%i - %li", i, [_goalDNA hammingDistance:[_cells objectAtIndex:i]]];
            [[_cells objectAtIndex:i] mutate:_mutationRate];
        }
//        NSLog(@"%@", s);
        return NO;
    } else return YES;
}
@end
