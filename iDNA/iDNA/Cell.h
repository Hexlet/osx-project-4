//
//  Cell.h
//  hexlet_dna
//
//  Created by Alexander Shvets on 02.11.12.
//  Copyright (c) 2012 Alexander Shvets. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Nucleotides.h"

@interface Cell : NSObject
{
    NSArray *nucleotides;
}

@property NSMutableArray *dna;
@property int hammingDistance;

- (id)initWithLength:(int)dnaLength;
- (id)initWithDNA:(NSArray*)dnaArr;
- (id)initWithString:(NSString*)dnaString;
- (void)mutate:(int)count;
- (int)hammingDistance:(id)cell;
- (NSString*)stringValue;

@end
