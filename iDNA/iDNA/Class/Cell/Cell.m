//
//  Cell.m
//  Project1_DNA
//
//  Created by Alexander on 06.11.12.
//  Copyright (c) 2012 Alexander. All rights reserved.
//

#import "Cell.h"

@implementation Cell
@synthesize DNA = _DNA;
-(id)initWithLength:(int)length
{
    
    self = [super init];
    if (self) {
        self.DNA = [[NSMutableArray alloc]init];
        variety = [NSArray arrayWithObjects:@"A",@"T",@"G",@"C",nil];
        for (int i = 0; i < length; i++) {
            @autoreleasepool {
                [self.DNA addObject:[variety objectAtIndex:arc4random()%[variety count]]];
            }
        }
    }

    return self;
}

-(int)hammingDistance:(Cell*)cell
{
    int hammingDist = 0;
    for (int i = 0; i < self.DNA.count; i++)
        if ([self.DNA objectAtIndex:i] != [cell.DNA objectAtIndex:i])
            hammingDist++;
    
    return hammingDist;
}
@end

@implementation Cell (mutator)
-(void)mutator:(int)percent
{
    NSMutableIndexSet *path = [[NSMutableIndexSet alloc]init];
    int _percent = (self.DNA.count / 100) * percent;
    while ([path count] < _percent) {
        [path addIndex:(arc4random() % self.DNA.count)];
    }
    
    [path enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        @autoreleasepool {
            NSString *tempString = [NSString stringWithString:[self.DNA objectAtIndex:idx]];
            while ([[self.DNA objectAtIndex:idx] isEqual:tempString]) {
                [self.DNA setObject:[variety objectAtIndex:arc4random()%[variety count]] atIndexedSubscript:idx];
            }
        }
    }];
    
}
@end