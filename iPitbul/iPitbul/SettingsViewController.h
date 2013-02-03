//
//  SettingsViewController.h
//  iPitbul
//
//  Created by Mykhailo Oleksiuk on 15.12.12.
//  Copyright (c) 2012 Mykhailo Oleksiuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SettingsViewController;

@protocol SettingsViewControllerDelegate
- (void)settingsViewControllerDidFinish:(SettingsViewController *)controller;
@end

@interface SettingsViewController : UIViewController

@property (weak, nonatomic) id <SettingsViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *pitbulPhoneNumberField;
@property (weak, nonatomic) IBOutlet UITextField *pitbulPasswordField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
