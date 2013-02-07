//
//  Cell.m
//  iDNA
//
//  Created by n on 25.12.12.
//  Copyright (c) 2012 witzawitz. All rights reserved.
//

#import "Cell.h"
#import "NSMutableArray+Shuffle.h"

@implementation Cell
{
    NSMutableArray *DNA;
    NSString *nucleotide;
}

-(id) init
{
    self = [super init];
    
    if (self)
    {
		[self initNucleotides];
        [self initDNAWithlength:100];
    }
    
    return self;
}

-(void) initNucleotides
{
	nucleotide = NUCLEOTIDES;
}

-(id) initWithDNAlength: (NSInteger) length
{
	if (self = [super init])
	{
		[self initNucleotides];
		[self initDNAWithlength:length];
	}
	return self;
}

-(id) initWithCell: (Cell *) cell
{
	if (self = [super init])
	{
		[self initNucleotides];
		
		NSInteger DNAsize = [cell DNAsize];
		DNA = [[NSMutableArray alloc] initWithCapacity:DNAsize];
		for (NSInteger i = 0; i < DNAsize; i++)
			[DNA setObject:[cell getDNAatIndex:i] atIndexedSubscript:i];
	}
	return self;
}

-(void) initDNAWithlength: (NSInteger) length
{
	int DNAsize = (int) length;
	
	// First init of DNA array.
	DNA = [[NSMutableArray alloc] initWithCapacity:DNAsize];
	
	// Fill with random nucleotides from corresponding array.
	for (NSInteger i=0; i < DNAsize; i++)
	{
		[DNA setObject:[self randomNucleotide] atIndexedSubscript:i];
	}
}

-(id) initWithString: (NSString *) dna
{
	if (self = [super init])
	{
		[self initNucleotides];
		DNA = [[NSMutableArray alloc] initWithCapacity:[dna length]];
		for (NSInteger i = 0; i < [dna length]; i++)
			[DNA setObject:[NSString stringWithFormat:@"%c", [dna characterAtIndex:i]] atIndexedSubscript:i];
	}
	return self;
}

-(int) hammingDistance: (Cell *) cell
{
    int dist = 0;
    
    // In case DNA size of two cells are differents.
    NSInteger minDNAsize = MIN([cell DNAsize], [self DNAsize]);
    NSInteger maxDNAsize = MAX([cell DNAsize], [self DNAsize]);
	
    // Comparing elements.
    for (NSInteger i=0; i<minDNAsize; i++)
    {
        if (![[cell getDNAatIndex:i] isEqualToString:[self getDNAatIndex:i]])
        {
            dist++;
        }
    }
    
    // The tail of one of DNA. Will add 0 in case sizes of DNA are equal.
    dist += (maxDNAsize - minDNAsize);
    
    return dist;
}


// Returns the size of DNA array.
-(NSInteger) DNAsize
{
    return [DNA count];
}

// Gets nucleotide at given index.
-(NSString *) getDNAatIndex: (NSInteger)index
{
    if ((index < 0) || (index >= [self DNAsize]))
        return nil;
    return [DNA objectAtIndex:index];
}

// Sets DNA nucleotide at given index.
-(void) setDNA: (NSString *) nucluotide atIndex: (NSInteger)index
{
    if ((index >= 0) && (index < [self DNAsize]))
    {
        [DNA setObject:nucluotide atIndexedSubscript:index];
    }
}

// Return random nucleotide from corresponding array.
-(NSString *) randomNucleotide
{
	return [NSString stringWithFormat:@"%c", [nucleotide characterAtIndex:arc4random_uniform((int)[nucleotide length])]];
}

-(NSString *) randomNucleotideExceptGiven: (NSString *) except
{
	@autoreleasepool
	{
		NSString *ncl = [nucleotide stringByReplacingOccurrencesOfString:except withString:@""];
		return [NSString stringWithFormat:@"%c", [ncl characterAtIndex:arc4random_uniform((int)[ncl length])]];
	}
}

-(void) setRandomDNAatIndex:(NSInteger) index
{
	[self setDNA:[self randomNucleotideExceptGiven:[self getDNAatIndex:index]] atIndex:index];
}

-(Cell *) crossWithCell: (Cell *) otherCell
{
	switch (arc4random_uniform(3))
	{
		case 0:
			return [self crossByHalfWithCell:otherCell];
		case 1:
			return [self crossByOnePercentWithCell:otherCell];
		case 2:
			return [self crossByPartsWithCell:otherCell];
		default:
			return self;
	}
}

-(Cell *) crossByHalfWithCell: (Cell *) otherCell
{
	if ([self DNAsize] != [otherCell DNAsize])
		return self;
	for (NSInteger i = [self DNAsize] / 2; i<[self DNAsize]; i++)
		[self setDNA:[otherCell getDNAatIndex:i] atIndex:i];
	return self;
}

-(Cell *) crossByOnePercentWithCell: (Cell *) otherCell
{
	if ([self DNAsize] != [otherCell DNAsize])
		return self;
	for (NSInteger i = 0; i < [self DNAsize]; i++)
		if (i % 2 == 1)
			[self setDNA:[otherCell getDNAatIndex:i] atIndex:i];
	return self;
}

-(Cell *) crossByPartsWithCell: (Cell *) otherCell
{
	if ([self DNAsize] != [otherCell DNAsize])
		return self;
	for (NSInteger i = [self DNAsize]/5; i < 4*[self DNAsize]/5; i++)
		[self setDNA:[otherCell getDNAatIndex:i] atIndex:i];
	return self;
}

-(void) mutate: (NSInteger) percentToReplace
{
    // Explicit number of element to replace.
    NSInteger replace = percentToReplace * [self DNAsize] / 100;
    
    // Some preparation in case of data out of range.
    if (replace < 0)
        replace = 0;
    if (replace > [self DNAsize])
        replace = [self DNAsize];
    
    // Nothing to do here.
    if (replace == 0)
        return;
    
    NSInteger i = 0;
    
    // Array that stores indices to replace.
    NSMutableArray *indicesToReplace = [[NSMutableArray alloc] initWithCapacity:[self DNAsize]];
    for (i = 0; i < [self DNAsize]; i++)
        [indicesToReplace setObject:[NSNumber numberWithInteger:i] atIndexedSubscript:i];
    // Shuffle it!
    [indicesToReplace shuffle];
    
    for (i = 0; i < replace; i++)
    {
        [self setRandomDNAatIndex:[[indicesToReplace objectAtIndex:i] integerValue]];
    }
}

// Returns DNA as string.
-(NSString *) DNAtoString
{
	NSMutableString *output = [[NSMutableString alloc] init];
    for (NSInteger i = 0; i < [self DNAsize]; i++)
    {
        [output appendString: [self getDNAatIndex:i]];
    }
	return output;
}

@end
