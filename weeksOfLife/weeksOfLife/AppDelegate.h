//
//  AppDelegate.h
//  weeksOfLife
//
//  Created by Александр Борунов on 17.01.13.
//  Copyright (c) 2013 Александр Борунов. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AddressBook/AddressBook.h>
#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "PreferencesController.h"
#import "AboutController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    PreferencesController *preferences;
    AboutController *about;
    NSMutableString *appendix;
    NSTimer *timer;
}


@property IBOutlet NSMenu *statusMenu;
@property NSStatusItem *statusItem;

@property NSDate *stopDate;


@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;
-(IBAction)showPreferencesController:(id)sender;
-(IBAction)showAboutController:(id)sender;

-(void)repaintStatusBar:(NSNotification *)notif;
- (void)selectorForTimer:(NSTimer *)aTimer;



@end
