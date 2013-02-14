//
//  Cell.h
//  iDNA
//
//  Created by n on 25.12.12.
//  Copyright (c) 2012 witzawitz. All rights reserved.
//

#import <Foundation/Foundation.h>
#define NUCLEOTIDES @"ATGC"

@interface Cell : NSObject

-(int) hammingDistance: (Cell *) cell;
-(NSInteger) DNAsize;
-(NSString *) getDNAatIndex: (NSInteger)index;
-(void) setDNA: (NSString *) nucluotide atIndex: (NSInteger)index;
-(id) initWithCell: (Cell *) cell;
-(id) initWithDNAlength: (NSInteger) length;
-(id) initWithString: (NSString *) dna;
-(NSString *) DNAtoString;
-(Cell *) crossWithCell: (Cell *) otherCell;
-(void) mutate: (NSInteger) percentToReplace;
-(NSString *) randomNucleotide;

@end
