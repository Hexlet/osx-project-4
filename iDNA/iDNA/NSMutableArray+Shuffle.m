//
//  NSMutableArray+Shuffle.m
//  iDNA
//
//  Created by n on 25.12.12.
//  Copyright (c) 2012 witzawitz. All rights reserved.
//

#import "NSMutableArray+Shuffle.h"

@implementation NSMutableArray (Shuffle)

// Everyday I'm shuffling!
-(void) shuffle
{
    for (NSInteger i = 0; i < [self count] - 1; i++)
    {
        [self exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform((int)([self count]-i)) + i];
    }
}

@end
