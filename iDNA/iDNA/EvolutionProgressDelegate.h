#import <Foundation/Foundation.h>

@protocol EvolutionProgressDelegate <NSObject>

-(void)evolutionStateHasChanged:(NSNotification *)notification;
-(void)evolutionGoalIsReached;

@end
