#import <Foundation/Foundation.h>

@class Cell;

@interface HybridizeStrategy : NSObject

-(NSString *)nucleobaseAtIndex:(NSInteger)index firstParent:(Cell *)cell1 secondParent:(Cell *)cell2;
+(HybridizeStrategy *)randomStrategy;

@end


@interface FiftyPercentHybridizeStrategy: HybridizeStrategy
@end

@interface OnePercentHybridizeStrategy: HybridizeStrategy
@end

@interface TwentySixtyTwentyPercentHybridizeStrategy: HybridizeStrategy
@end
