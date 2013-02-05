//
//  PreferencesController.h
//  iDNA
//
//  Created by Admin on 04.02.13.
//  Copyright (c) 2013 Kabest. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const IDNAPopulationSize;
extern NSString *const IDNADNALength;
extern NSString *const IDNAMutationRate;

@interface PreferencesController : NSObject

-(void)setPopulationSize:(NSInteger)value;
-(void)setDNALength:(NSInteger)value;
-(void)setMutationRate:(NSInteger)value;

-(NSInteger)populationSize;
-(NSInteger)DNALength;
-(NSInteger)mutationRate;

@end
