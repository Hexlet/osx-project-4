//
//  PitbulAction.m
//  iPitbul
//
//  Created by Mykhailo Oleksiuk on 12/22/12.
//  Copyright (c) 2012 Mykhailo Oleksiuk. All rights reserved.
//

#import "PitbulAction.h"

@implementation PitbulAction

+ (PitbulAction *)initWithAction:(NSString *)action andTitle:(NSString *)title {
    return [PitbulAction initWithAction:action andTitle:title andType:SMS];
}

+ (PitbulAction *)initWithAction:(NSString *)action andTitle:(NSString *)title andType:(PitbulActionType)type {
    PitbulAction *pitbulAction = [[PitbulAction alloc] init];
    pitbulAction.action = action;
    pitbulAction.title = title;
    pitbulAction.type = type;
    return pitbulAction;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[action=%@, title=%@, type=%u]", self.action, self.title, self.type];
}

@end
