//
//  Settings.m
//  iPitbul
//
//  Created by Mykhailo Oleksiuk on 30.12.2012.
//  Copyright (c) 2012 Mykhailo Oleksiuk. All rights reserved.
//

#import "Settings.h"
#import "Constants.h"

@implementation Settings

+ (Settings *)instance {
    static Settings *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Settings alloc] init];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        sharedInstance.pitbulPhoneNumber = [userDefaults objectForKey:PITBUL_PHONE_NUMBER];
        sharedInstance.pitbulPassword = [userDefaults objectForKey:PITBUL_PASSWORD];
        
        NSLog(@"Initialized Settings: %@", sharedInstance);
    });
    return sharedInstance;
}

- (void)save {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.pitbulPhoneNumber forKey:PITBUL_PHONE_NUMBER];
    [userDefaults setObject:self.pitbulPassword forKey:PITBUL_PASSWORD];
    [userDefaults synchronize];
    
    NSLog(@"Saved Settings: %@", self);

    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:self forKey:PITBUL_ACTION_IN_NOTIFICATION];
    [[NSNotificationCenter defaultCenter] postNotificationName:SETTINGS_CHANGED_NOTIFICATION object:self userInfo:userInfo];
}

- (BOOL)isPitbulSettingsConfigured {
    return ([self.pitbulPhoneNumber length] !=0) && ([self.pitbulPassword length] != 0);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[pitbulPhoneNumber=%@, pitbulPassword=%@]", self.pitbulPhoneNumber, self.pitbulPassword];
}

@end
