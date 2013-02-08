//
//  IDNCell.m
//  IDNA
//
//  Created by Dmitriy Zhukov on 07.01.13.
//  Copyright (c) 2013 Dmitriy Zhukov. All rights reserved.
//

#import "IDNCell.h"

@implementation IDNCell

- (id)init {
    self= [super init];
    if (self) {
        self.rangeOfDNACellValues = @"ATGC";
        self.unitDistanceToTargetDNA = 0;
        self.arrayCapacity=0;
        self.DNA = [[NSMutableArray alloc]init];
    }
    return self;
}

- (id)initWithRandom:(unsigned int)r {
    self=[self init];
    if (self) { srandom(r); }
    return self;
}

- (void) fillDNAArrayWithCapacity: (NSInteger)fCapacity {
    
    srandom (random);
    self.arrayCapacity = fCapacity;
    NSMutableArray* setDNA = [NSMutableArray arrayWithCapacity:self.arrayCapacity];
    
    for (NSInteger i = 0 ; i < self.arrayCapacity; i++) {
        [setDNA addObject:[NSString stringWithFormat:@"%C", [self.rangeOfDNACellValues characterAtIndex: arc4random() % [self.rangeOfDNACellValues length]]]];
    }
    self.DNA = setDNA;
}

- (NSInteger) hammingDistance: (IDNCell*) anotherDNA {
    NSInteger count = 0;
    for (NSInteger i = 0 ; i < self.arrayCapacity; i++) {
        if ([[self.DNA objectAtIndex:i] isNotEqualTo:[anotherDNA.DNA objectAtIndex: i]]) {
            count++;
        }
    }
    return count;
}

- (void)mutate: (NSInteger) procentageOfMutations {
    
    float a = (self.arrayCapacity*procentageOfMutations)/100.0;
    NSInteger numberOfcells = ceil(a);
    NSMutableIndexSet *indexSetDNA = [[NSMutableIndexSet alloc] init];
    
    for (NSInteger i = 0; i < numberOfcells; i++) {
        NSInteger indexGen = arc4random ()%self.arrayCapacity;
        
        if (![indexSetDNA containsIndex:indexGen]) {
            [indexSetDNA addIndex:indexGen];
            
            for(;;) {
                NSString *changes =[NSString stringWithFormat:@"%C", [self.rangeOfDNACellValues characterAtIndex: arc4random() % [self.rangeOfDNACellValues length]]];
                
                if (![[self.DNA objectAtIndex: indexGen] isEqualToString:changes]) {
                    [self.DNA replaceObjectAtIndex:indexGen withObject:changes];
                    break;
                }
            }
            
        } else {i--;}
    }
}


@end
