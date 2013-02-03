//
//  PitbulCommandProvider.h
//  iPitbul
//
//  Created by Mykhailo Oleksiuk on 12/2/12.
//  Copyright (c) 2012 Mykhailo Oleksiuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PitbulAction;

@interface PitbulActionProvider : NSObject

@property (nonatomic, retain, getter = managementActions) NSArray *managementActions;
@property (nonatomic, retain, getter = serviceActions) NSArray *serviceActions;
@property (nonatomic, retain, getter = totalActions) NSArray *totalActions;

+ (PitbulActionProvider *)instance;

- (PitbulAction *)actionByTitle:(NSString *)title;

@end
