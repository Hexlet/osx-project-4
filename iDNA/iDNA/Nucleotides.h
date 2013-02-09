//
//  Nucleotides.h
//  iDNA
//
//  Created by Alexander Shvets on 02.01.13.
//  Copyright (c) 2013 Alexander Shvets. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Nucleotides : NSObject{
    NSArray* nucleos;
}

+ (Nucleotides *) sharedInstance;
- (NSArray*) getNucleotides;

@end
