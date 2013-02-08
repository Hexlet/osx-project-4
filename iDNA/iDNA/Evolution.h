#import <Foundation/Foundation.h>
#import "EvolutionProgressDelegate.h"

@class Cell;

@interface Evolution : NSObject {
    BOOL paused;
    BOOL inProgress;
    NSMutableArray *population;
    NSInteger populationSize;
    NSInteger generation;
    NSInteger mutationRate;
    NSInteger dnaLength;
    NSInteger closestDistanceDuringEvolution;
    Cell *goalCell;
    id<EvolutionProgressDelegate> delegate;
}

@property (assign) NSInteger populationSize;
@property (assign) NSInteger dnaLength;
@property (assign) NSInteger mutationRate;
@property (assign) BOOL paused;
@property (assign) BOOL inProgress;
@property (readonly) NSInteger generation;
@property (readonly) NSString *goalDNA;
@property id<EvolutionProgressDelegate> delegate;

-(void)start;
-(void)stop;
-(void)pause;
-(void)resume;
-(void)loadGoalDNA:(NSString *)dnaString;

@end
