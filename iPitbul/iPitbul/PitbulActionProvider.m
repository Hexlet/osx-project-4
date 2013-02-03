//
//  PitbulCommandProvider.m
//  iPitbul
//
//  Created by Mykhailo Oleksiuk on 12/2/12.
//  Copyright (c) 2012 Mykhailo Oleksiuk. All rights reserved.
//

#import "PitbulActionProvider.h"
#import "Constants.h"
#import "Settings.h"
#import "PitbulAction.h"

@implementation PitbulActionProvider

+ (PitbulActionProvider *)instance {
    static PitbulActionProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PitbulActionProvider alloc] init];
        
        NSString *pitbulPhoneNumber = [[Settings instance] pitbulPhoneNumber];
        
        sharedInstance.managementActions = [NSArray arrayWithObjects:
                              [PitbulAction initWithAction:pitbulPhoneNumber andTitle:pitbulPhoneNumber andType:CALL],
                              [PitbulAction initWithAction:MA_AM andTitle:NSLocalizedString(MA_AM, nil)],
                              [PitbulAction initWithAction:MA_DM andTitle:NSLocalizedString(MA_DM, nil)],
                              nil];
        
        sharedInstance.serviceActions = [NSArray arrayWithObjects:
                           [PitbulAction initWithAction:SA_GM andTitle:NSLocalizedString(SA_GM, nil)],
                           [PitbulAction initWithAction:SA_ST andTitle:NSLocalizedString(SA_ST, nil)],
                           [PitbulAction initWithAction:SA_PW andTitle:NSLocalizedString(SA_PW, nil)],
                           [PitbulAction initWithAction:SA_ID andTitle:NSLocalizedString(SA_ID, nil)],
                           [PitbulAction initWithAction:SA_IM andTitle:NSLocalizedString(SA_IM, nil)],
                           [PitbulAction initWithAction:SA_GL andTitle:NSLocalizedString(SA_GL, nil)],
                           [PitbulAction initWithAction:SA_S1 andTitle:NSLocalizedString(SA_S1, nil)],
                           [PitbulAction initWithAction:SA_S0 andTitle:NSLocalizedString(SA_S0, nil)],
                           [PitbulAction initWithAction:SA_SM andTitle:NSLocalizedString(SA_SM, nil)],
                           nil];
        
        sharedInstance.totalActions = [sharedInstance.managementActions arrayByAddingObjectsFromArray:sharedInstance.serviceActions];
        
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance
                                                 selector:@selector(receiveSettingsChangedNotification:)
                                                     name:SETTINGS_CHANGED_NOTIFICATION
                                                   object:nil];
        
        NSLog(@"Initialized PitbulActionProvider:\n %@", sharedInstance);
    });
    return sharedInstance;
}

- (void) receiveSettingsChangedNotification:(NSNotification *) notification
{ 
    if ([[notification name] isEqualToString:SETTINGS_CHANGED_NOTIFICATION]) {
        NSLog(@"%@", notification);
        Settings *updatedSettings = [[notification userInfo] objectForKey:PITBUL_ACTION_IN_NOTIFICATION];
        NSString *updatedPitbulPhoneNumber = [updatedSettings pitbulPhoneNumber];
        PitbulAction *callAction = [self.managementActions objectAtIndex:0];
        [callAction setAction:updatedPitbulPhoneNumber];
        [callAction setTitle:updatedPitbulPhoneNumber];
    }
}

- (PitbulAction *)actionByTitle:(NSString *)title {
    for(PitbulAction *pa in self.totalActions) {
        if ([title isEqualToString:pa.title]) {
            return pa;
        }
    }
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Management Actions:[%@]\nService Actions:[%@]\nTotal Actions:[%@]", self.managementActions, self.serviceActions, self.totalActions];
}

@end
