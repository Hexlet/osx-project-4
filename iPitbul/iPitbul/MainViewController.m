//
//  MainViewController.m
//  iPitbul
//
//  Created by Mykhailo Oleksiuk on 11/21/12.
//  Copyright (c) 2012 Mykhailo Oleksiuk. All rights reserved.
//

#import "MainViewController.h"
#import "GenericUtils.h"
#import "PitbulActionProvider.h"
#import "PitbulAction.h"
#import "Settings.h"

#define NUMBER_OF_SECTIONS_IN_TABLE 2
#define DEFAULT_TABLE_HEADER_HEIGHT 44
#define DEFAULT_TABLE_HEADER_WIDTH 300

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![[Settings instance] isPitbulSettingsConfigured]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        SettingsViewController *settingsViewController = [storyboard instantiateViewControllerWithIdentifier:@"settingsView"];
        settingsViewController.delegate = self;
        [self presentViewController:settingsViewController animated:animated completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)settingsViewControllerDidFinish:(SettingsViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)aboutViewControllerDidFinish:(AboutViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"aboutAlternate"]
        || [[segue identifier] isEqualToString:@"settingsAlternate"]) {
        
        [[segue destinationViewController] setDelegate:self];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	switch (result) {
        case MessageComposeResultFailed:
            [GenericUtils errorAlertWithTitle:NSLocalizedString(@"error.title", nil) andMessage:NSLocalizedString(@"error.sms.message.unableToSendSms", nil)];
			break;
		case MessageComposeResultCancelled:
			NSLog(@"Cancelled");
			break;
		case MessageComposeResultSent:
            NSLog(@"Done");
			break;
	}
    
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return NUMBER_OF_SECTIONS_IN_TABLE;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return DEFAULT_TABLE_HEADER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle;
    
    if(section == 0) {
        sectionTitle = NSLocalizedString(@"main.view.table.header.management.actions", nil);
    } else {
        sectionTitle = NSLocalizedString(@"main.view.table.header.service.actions", nil);
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 0, DEFAULT_TABLE_HEADER_WIDTH, DEFAULT_TABLE_HEADER_HEIGHT);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor grayColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(20, 0, DEFAULT_TABLE_HEADER_WIDTH, DEFAULT_TABLE_HEADER_HEIGHT)];
    [view addSubview:label];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    PitbulActionProvider *provider = [PitbulActionProvider instance];
    
    if(section == 0) {
        return [[provider managementActions] count];
    } else {
        return [[provider serviceActions] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PitbulActionProvider *provider = [PitbulActionProvider instance];
    static NSString *simpleTableIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = [[[provider managementActions] objectAtIndex:indexPath.row] title];
    } else {
        cell.textLabel.text = [[[provider serviceActions] objectAtIndex:indexPath.row] title];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PitbulActionProvider *provider = [PitbulActionProvider instance];
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *title = selectedCell.textLabel.text;
    
    [self handlePitbulAction: [provider actionByTitle:title]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)handlePitbulAction:(PitbulAction *)pitbulAction {
    Settings *settings = [Settings instance];
    
    if (pitbulAction != nil && [settings isPitbulSettingsConfigured]) {
        if (pitbulAction.type == CALL) {
            [self makeCallToRecipient:pitbulAction.action];
        } else if (pitbulAction.type == SMS) {
            NSString *phone = [settings pitbulPhoneNumber];
            NSString *password = [settings pitbulPassword];
            NSString *sms = [NSString stringWithFormat:@"%@{%@}", password, pitbulAction.action];
            
            [self sendSmsToRecipient:phone WithBody:sms];
        } else {
            NSLog(@"Unknown action detected: %@", pitbulAction);
        }
    }
}

- (void)makeCallToRecipient:(NSString *)recipient {
    if([[GenericUtils device] isEqualToString:@"iPhone"]) {
        NSString *phone = [NSString stringWithFormat:@"tel:%@", recipient];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phone]];
    } else {
        [GenericUtils errorAlertWithTitle:NSLocalizedString(@"error.title", nil) andMessage:NSLocalizedString(@"error.sms.message.unableToMakeCall", nil)];
    }
}

- (void)sendSmsToRecipient:(NSString *)recipient WithBody:(NSString *)body {
    if([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
		controller.body = body;
		controller.recipients = [NSArray arrayWithObjects:recipient, nil];
		controller.messageComposeDelegate = self;
        
		[self presentViewController:controller animated:YES completion:nil];
	} else {
        NSLog(@"Unable to send sms to recipient=%@ with body=%@", recipient, body);
        [GenericUtils errorAlertWithTitle:NSLocalizedString(@"error.title", nil) andMessage:NSLocalizedString(@"error.sms.message.unableToSendSms", nil)];
    }
}

@end
