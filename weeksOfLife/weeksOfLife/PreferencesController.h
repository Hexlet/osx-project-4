//
//  PreferencesController.h
//  weeksOfLife
//
//  Created by Александр Борунов on 17.01.13.
//  Copyright (c) 2013 Александр Борунов. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AddressBook/AddressBook.h>

extern NSString *const DauBirthDayKey;
extern NSString *const DauStopDayKey;
extern NSString *const DauYearsKey;
extern NSString *const DauRunAtLoginKey;
extern NSString *const DauTitleColor;

extern NSString *const DauWeeksMustRepaintNotification;

@interface PreferencesController : NSWindowController {
    IBOutlet  NSDatePicker *birthday;
    IBOutlet  NSDatePicker *stopDay;
    IBOutlet NSTextField *yearsTextField;
    IBOutlet NSButton *checkBox;
    IBOutlet NSColorWell *titleColor;
    NSMutableDictionary *titleAttributes;
}


+(void) addAppAsLoginItem;
+(void) deleteAppFromLoginItem;


+(NSDate*)prefBirthDate;
+(void)setPrefBirthData:(NSDate*)bd;

+(NSInteger)prefYears;
+(void)setPrefYears:(NSInteger)ye;

+(NSDate*)prefStopDate;
+(void)setPrefStopData:(NSDate*)sd;

+(BOOL)prefRunAtLogin;
+(void)setPrefRunAtLogin:(BOOL)isrun;

+(NSColor*)prefTitleColor;
+(void)setPrefTitleColor:(NSColor*)c;


-(NSDictionary*)titleAttributes;

-(IBAction)changeBirthDay:(id)sender;
-(IBAction)changeYears:(id)sender;
-(IBAction)changeStopDay:(id)sender;
-(IBAction)changeRunAtLogin:(id)sender;
-(IBAction)changeTitleColor:(id)sender;

@end
