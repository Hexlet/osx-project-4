//
//  PreferencesController.h
//  iDNA
//
//  Created by alex on 01/02/2013.
//  Copyright (c) 2013 alex. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const PrefPopulationSize;
extern NSString *const PrefDNALength;
extern NSString *const PrefMutationRate;

@interface PreferencesController : NSObject

-(void)setPopulationSize:(NSInteger)value;
-(void)setDNALength:(NSInteger)value;
-(void)setMutationRate:(NSInteger)value;

-(NSInteger)populationSize;
-(NSInteger)DNALength;
-(NSInteger)mutationRate;

@end
