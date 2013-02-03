//
//  SettingsViewController.m
//  iPitbul
//
//  Created by Mykhailo Oleksiuk on 15.12.12.
//  Copyright (c) 2012 Mykhailo Oleksiuk. All rights reserved.
//

#import "SettingsViewController.h"
#import "GenericUtils.h"
#import "Settings.h"
#import "Constants.h"

@interface SettingsViewController ()
- (BOOL)isValidatePitbulPhoneNumber;
- (BOOL)isValidatePitbulPassword;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Settings *settings = [Settings instance];
    
    _pitbulPhoneNumberField.text = [settings pitbulPhoneNumber];
    _pitbulPasswordField.text = [settings pitbulPassword];
    
    if (![settings isPitbulSettingsConfigured]) {
        [_cancelButton setEnabled:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)save:(id)sender {
    if (![self isValidatePitbulPhoneNumber]) {
        [GenericUtils errorAlertWithTitle:NSLocalizedString(@"error.title", nil) andMessage:NSLocalizedString(@"settings.view.error.message.invalidPitbulPhoneNumber", nil)];
        return;
    }
    if (![self isValidatePitbulPassword]) {
        [GenericUtils errorAlertWithTitle:NSLocalizedString(@"error.title", nil) andMessage:NSLocalizedString(@"settings.view.error.message.invalidPitbulPassword", nil)];
        return;
    }
    
    Settings *settings = [Settings instance];
    [settings setPitbulPhoneNumber:self.pitbulPhoneNumberField.text];
    [settings setPitbulPassword:self.pitbulPasswordField.text];
    [settings save];
    
    [self.delegate settingsViewControllerDidFinish:self];
}

- (IBAction)cancel:(id)sender {  
    [self.delegate settingsViewControllerDidFinish:self];
}


- (BOOL)isValidatePitbulPhoneNumber {
    return [_pitbulPhoneNumberField.text length] != 0;
}

- (BOOL)isValidatePitbulPassword {
    return [_pitbulPasswordField.text length] == 4;
}

@end
