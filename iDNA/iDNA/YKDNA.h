//
//  YKDNA.h
//  iDNA
//
//  Created by Yuri Kirghisov on 17.12.12.
//  Copyright (c) 2012 Yuri Kirghisov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YKDNA : NSObject {
//    NSArray *dnaLetters;
}

@property (retain) NSString *dnaString;

- (YKDNA *)initWithLength:(NSUInteger)length;

- (NSInteger)hammingDistanceToDNA:(YKDNA *)aDNA;
- (void)mutateWithPercentage:(NSUInteger)percentage;
- (YKDNA *)dnaByBreedingWithDNA:(YKDNA *)aDNA;

@end
