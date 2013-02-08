#import "HybridizeStrategy.h"
#import "Cell.h"

@implementation HybridizeStrategy

+(HybridizeStrategy *)randomStrategy {
    int randomIndex = random() % 3;
    if (randomIndex == 0) {
        return [[FiftyPercentHybridizeStrategy alloc] init];
    } else if (randomIndex == 1) {
        return [[OnePercentHybridizeStrategy alloc] init];
    } else {
        return [[TwentySixtyTwentyPercentHybridizeStrategy alloc] init];
    }
}

-(NSString *)nucleobaseAtIndex:(NSInteger)index firstParent:(Cell *)cell1 secondParent:(Cell *)cell2 {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end



@implementation FiftyPercentHybridizeStrategy

-(NSString *)nucleobaseAtIndex:(NSInteger)index firstParent:(Cell *)cell1 secondParent:(Cell *)cell2 {
    NSInteger threshold = (NSInteger)([cell1.dna count] * 0.5);
    Cell *cell = index < threshold ? cell1 : cell2;
    return [cell nucleobaseAtIndex:index];
}

@end



@implementation OnePercentHybridizeStrategy

-(NSString *)nucleobaseAtIndex:(NSInteger)index firstParent:(Cell *)cell1 secondParent:(Cell *)cell2 {
    Cell *cell = index % 2 == 0 ? cell1 : cell2;
    return [cell nucleobaseAtIndex:index];
}

@end



@implementation TwentySixtyTwentyPercentHybridizeStrategy

-(NSString *)nucleobaseAtIndex:(NSInteger)index firstParent:(Cell *)cell1 secondParent:(Cell *)cell2 {
    NSInteger threshold1 = (NSInteger)([cell1.dna count] * 0.2);
    NSInteger threshold2 = (NSInteger)([cell1.dna count] * 0.8);
    Cell *cell = index < threshold1 || index >= threshold2 ? cell1 : cell2;
    return [cell nucleobaseAtIndex:index];
}

@end

