//
//  MainViewController.h
//  iPitbul
//
//  Created by Mykhailo Oleksiuk on 11/21/12.
//  Copyright (c) 2012 Mykhailo Oleksiuk. All rights reserved.
//

#import "AboutViewController.h"
#import "SettingsViewController.h"

@class PitbulAction;

@interface MainViewController : UIViewController <SettingsViewControllerDelegate, AboutViewControllerDelegate, MFMessageComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;

- (void)handlePitbulAction:(PitbulAction *)pitbulAction;
- (void)makeCallToRecipient:(NSString *)recipient;
- (void)sendSmsToRecipient:(NSString *)recipient WithBody:(NSString *)textBody;

@end
