#import "Evolution.h"
#import "Cell.h"
#import "HybridizeStrategy.h"

NSInteger compareCellsByHammingDistanceToTargetCell(Cell *cell1, Cell *cell2, void *context) {
    Cell *goalCell = (__bridge Cell *)(context);
    int hammingDistance1 = [goalCell hammingDistance:cell1];
    int hammingDistance2 = [goalCell hammingDistance:cell2];
    if (hammingDistance1 < hammingDistance2) {
        return (NSComparisonResult) NSOrderedAscending;
    } else if (hammingDistance1 > hammingDistance2) {
        return (NSComparisonResult) NSOrderedDescending;
    } else {
        return (NSComparisonResult) NSOrderedSame;
    }
}

@implementation Evolution

@synthesize populationSize, mutationRate, inProgress, paused, generation, delegate;

-(id)init {
    if (self = [super init]) {
        srandom((unsigned)time(NULL));
        inProgress = NO;
        paused = NO;
        generation = 0;
    }
    return self;
}

-(void)start {
    inProgress = YES;
    paused = NO;
    generation = 0;
    closestDistanceDuringEvolution = dnaLength;
    [self generatePopulation];
    [self performSelectorInBackground:@selector(nextGeneration) withObject:nil];
}

-(void)nextGeneration {
    [self sortPopulation];
    NSInteger closestDistance = [[population objectAtIndex:0] hammingDistance:goalCell];
    // NSLog(@"step: %li, closest: %li, %@", generation, closestDistance, [population objectAtIndex:0]);
    if (closestDistanceDuringEvolution > closestDistance) {
        closestDistanceDuringEvolution = closestDistance;
    }
    if (closestDistance == 0) {
        [self postProgressNotification];
        [self stop];
        if (self.delegate) {
            [delegate evolutionGoalIsReached];
        }
        return;
    }
    generation++;
    [self hybridizePopulation];
    [self mutatePopulation];
    [self postProgressNotification];
    if (paused == NO && inProgress == YES) {
        [self nextGeneration];
    }
}

-(void)mutatePopulation {
    for (Cell *cell in population) {
        [cell mutate:mutationRate];
    }
}

-(void)hybridizePopulation {
    int losersThreshold = (int)(populationSize * 0.5);
    for (int i = losersThreshold; i < populationSize; i++) {
        Cell *mother = [population objectAtIndex: arc4random_uniform(losersThreshold)];
        Cell *father = [population objectAtIndex: arc4random_uniform(losersThreshold)];
        Cell *child = [self hybridizeCell:mother withCell:father];
        [population replaceObjectAtIndex:i withObject:child];
    }
}

-(Cell *)hybridizeCell:(Cell *)cell1 withCell:(Cell *)cell2 {
    NSMutableArray *dna = [NSMutableArray arrayWithCapacity:dnaLength];
    HybridizeStrategy *hybridizeStrategy = [HybridizeStrategy randomStrategy];
    for (int i = 0; i < dnaLength; i++) {
        [dna addObject:[hybridizeStrategy nucleobaseAtIndex:i firstParent:cell1 secondParent:cell2]];
    }
    return [[Cell alloc] initWithDNA:dna];
}

-(void) generateGoalCell {
    [self willChangeValueForKey:@"goalDNA"];
    goalCell = [[Cell alloc] initWithRandomDNAOfLength:dnaLength];
    [self didChangeValueForKey:@"goalDNA"];
}

-(void) generatePopulation {
    population = [[NSMutableArray alloc] init];
    for (int i = 0; i < populationSize; i++) {
        [population addObject:[[Cell alloc] initWithRandomDNAOfLength:dnaLength]];
    }
}

-(void) sortPopulation {
    [population sortUsingFunction:compareCellsByHammingDistanceToTargetCell context:(__bridge void *)(goalCell)];
}

-(void)stop {
    inProgress = NO;
    paused = NO;
}

-(void)pause {
    paused = YES;
}

-(void)resume {
    paused = NO;
    [self performSelectorInBackground:@selector(nextGeneration) withObject:nil];
}

-(void)postProgressNotification {
    if (!self.delegate) {
        return;
    }
    NSInteger bestMatchPercent = (NSInteger)(100 * (dnaLength - closestDistanceDuringEvolution) / dnaLength);
    NSDictionary *userInfo = @{ @"generation": [NSNumber numberWithInteger:generation],
                                 @"bestMatch": [NSNumber numberWithInteger:bestMatchPercent] };
    NSNotification *notification = [NSNotification notificationWithName:@"evolutionProgressChange" object:nil userInfo:userInfo];
    [delegate evolutionStateHasChanged:notification];
}

-(NSString *)goalDNA {
    return [goalCell description];
}

-(void)setDnaLength:(NSInteger)l {
    dnaLength = l;
    [self generateGoalCell];
}

-(NSInteger)dnaLength {
    return dnaLength;
}

-(void)loadGoalDNA:(NSString *)dnaString {
    NSMutableArray *goalDNA = [NSMutableArray arrayWithCapacity:dnaString.length];
    NSRange range;
    range.length = 1;
    for (int i = 0; i < dnaString.length; i++) {
        range.location = i;
        [goalDNA addObject:[dnaString substringWithRange:range]];
    }
    [self willChangeValueForKey:@"goalDNA"];
    [self willChangeValueForKey:@"dnaLength"];
    dnaLength = dnaString.length;
    goalCell = [[Cell alloc] initWithDNA:goalDNA];
    [self didChangeValueForKey:@"goalDNA"];
    [self didChangeValueForKey:@"dnaLength"];
}

@end
