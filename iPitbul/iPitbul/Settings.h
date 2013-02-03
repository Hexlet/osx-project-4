//
//  Settings.h
//  iPitbul
//
//  Created by Mykhailo Oleksiuk on 30.12.2012.
//  Copyright (c) 2012 Mykhailo Oleksiuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

@property (strong) NSString *pitbulPhoneNumber;
@property (strong) NSString *pitbulPassword;

+ (Settings *)instance;

- (void)save;
- (BOOL)isPitbulSettingsConfigured;

@end
