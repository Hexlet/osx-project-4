//
//  Nucleotides.m
//  iDNA
//
//  Created by Alexander Shvets on 02.01.13.
//  Copyright (c) 2013 Alexander Shvets. All rights reserved.
//

#import "Nucleotides.h"

@implementation Nucleotides

static Nucleotides *sNucleotides = nil;

+ (Nucleotides *) sharedInstance
{
    @synchronized(self)
    {
        if(sNucleotides == nil) sNucleotides = [[Nucleotides alloc] init];
    }
    
    return sNucleotides;
}

- (id) init {
    if(sNucleotides == nil) NSLog(@"Nucleotides singleton initialized");
    
    self = [super init];
    if(self) nucleos = [NSArray arrayWithObjects:@"A", @"T", @"G", @"C", nil];
    
    return self;
}

- (NSArray*) getNucleotides
{
    return nucleos;
}

@end
