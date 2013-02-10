//
//  PreferencesController.m
//  weeksOfLife
//
//  Created by Александр Борунов on 17.01.13.
//  Copyright (c) 2013 Александр Борунов. All rights reserved.
//

#import "PreferencesController.h"


@implementation PreferencesController

NSString *const DauBirthDayKey = @"DauBirthDayKey";
NSString *const DauStopDayKey = @"DauStopDayKey";
NSString *const DauYearsKey = @"DauYearsKey";
NSString *const DauRunAtLoginKey = @"DauRunAtLoginKey";
NSString *const DauTitleColor = @"DauTitleColor";
NSString *const DauWeeksMustRepaintNotification = @"DauWeeksMustRepaintNotification";

+(void)initialize{
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
    ABPerson *aPerson = [[ABAddressBook sharedAddressBook] me];
    NSDate *myBirthday;
    if (aPerson == nil){
        myBirthday = [NSDate dateWithString:@"1980-01-01 20:00:00 +0000"];
    } else {
        myBirthday = [aPerson valueForProperty:kABBirthdayProperty];
    }

    NSData *temporaryData = [NSKeyedArchiver archivedDataWithRootObject:myBirthday];
    [defaultValues setObject:temporaryData forKey:DauBirthDayKey];

    
    NSInteger years = 75;
    [defaultValues setObject:[NSNumber numberWithInteger:years] forKey:DauYearsKey];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    
    [offsetComponents setYear:years];
    NSDate *stopDate = [gregorian dateByAddingComponents:offsetComponents toDate:myBirthday options:0];
    temporaryData = [NSKeyedArchiver archivedDataWithRootObject:stopDate];
    [defaultValues setObject:temporaryData forKey:DauStopDayKey];
    
    [defaultValues setObject:[NSNumber numberWithBool:YES] forKey:DauRunAtLoginKey];
    [self addAppAsLoginItem];
    
    temporaryData = [NSKeyedArchiver archivedDataWithRootObject:[NSColor blueColor]];
    [defaultValues setObject:temporaryData forKey:DauTitleColor];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}


+(void)setPrefBirthData:(NSDate*)bd {
    NSData *dateAsData = [NSKeyedArchiver archivedDataWithRootObject:bd];
    [[NSUserDefaults standardUserDefaults] setObject:dateAsData forKey:DauBirthDayKey];    
}
+(NSDate*)prefBirthDate{
    NSData *dateAsData = [[NSUserDefaults standardUserDefaults] objectForKey:DauBirthDayKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:dateAsData];
}
+(void)setPrefStopData:(NSDate*)sd {
    NSData *dateAsData = [NSKeyedArchiver archivedDataWithRootObject:sd];
    [[NSUserDefaults standardUserDefaults] setObject:dateAsData forKey:DauStopDayKey];
}
+(NSDate*)prefStopDate{
    NSData *dateAsData = [[NSUserDefaults standardUserDefaults] objectForKey:DauStopDayKey];
    return [NSKeyedUnarchiver unarchiveObjectWithData:dateAsData];
}
+(void)setPrefYears:(NSInteger)ye{
    [[NSUserDefaults standardUserDefaults] setInteger:ye forKey:DauYearsKey];
}
+(NSInteger)prefYears{
    return [[NSUserDefaults standardUserDefaults] integerForKey:DauYearsKey];
}
+(BOOL)prefRunAtLogin{
    return [[NSUserDefaults standardUserDefaults] boolForKey:DauRunAtLoginKey];
}
+(void)setPrefRunAtLogin:(BOOL)isrun{
    [[NSUserDefaults standardUserDefaults]setBool:isrun forKey:DauRunAtLoginKey];
}
+(NSColor*)prefTitleColor{
    NSData *colorAsData = [[NSUserDefaults standardUserDefaults] objectForKey:DauTitleColor];
    return [NSKeyedUnarchiver unarchiveObjectWithData:colorAsData];
}
+(void)setPrefTitleColor:(NSColor*)c{
    NSData *colorAsData = [NSKeyedArchiver archivedDataWithRootObject:c];
    [[NSUserDefaults standardUserDefaults] setObject:colorAsData forKey:DauTitleColor];
}



-(id) init{
    if (self = [super initWithWindowNibName:@"PreferencesController"]){
        titleAttributes = [NSMutableDictionary dictionary];
        [titleAttributes setObject:[NSFont boldSystemFontOfSize:12.0] forKey:NSFontAttributeName];
        [titleAttributes setObject:[PreferencesController prefTitleColor] forKey:NSForegroundColorAttributeName];
    }
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{    
    [super windowDidLoad];
    [birthday setDateValue:[PreferencesController prefBirthDate]];
    [stopDay setDateValue:[PreferencesController prefStopDate]];
    [yearsTextField setIntegerValue:[PreferencesController prefYears]];
    NSInteger checkBoxState = ([PreferencesController prefRunAtLogin])? NSOnState : NSOffState;
    [checkBox setState:checkBoxState];
    [titleColor setColor:[PreferencesController prefTitleColor]];
}


-(IBAction)changeBirthDay:(id)sender{
    [PreferencesController setPrefBirthData:[birthday dateValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:[yearsTextField integerValue]];
    NSDate *stopDate = [gregorian dateByAddingComponents:offsetComponents toDate:[birthday dateValue] options:0];
    [stopDay setDateValue:stopDate];
    [PreferencesController setPrefStopData:stopDate];
    [[NSNotificationCenter defaultCenter] postNotificationName:DauWeeksMustRepaintNotification object:self];
}
-(IBAction)changeYears:(id)sender{
    // полученное изменение года просто сохраним
    NSInteger years = [yearsTextField integerValue];
    [PreferencesController setPrefYears:years];
    // и дату конца посчитаем как дату рождения плюс измененные годы
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:years];
    NSDate *stopDate = [gregorian dateByAddingComponents:offsetComponents toDate:[birthday dateValue] options:0];
    [stopDay setDateValue:stopDate];
    [PreferencesController setPrefStopData:stopDate];
    [[NSNotificationCenter defaultCenter] postNotificationName:DauWeeksMustRepaintNotification object:self];
}
-(IBAction)changeStopDay:(id)sender{
    [PreferencesController setPrefStopData:[stopDay dateValue]];
    [[NSNotificationCenter defaultCenter] postNotificationName:DauWeeksMustRepaintNotification object:self];
}
-(IBAction)changeRunAtLogin:(id)sender{
    BOOL oldState = [PreferencesController prefRunAtLogin];
    BOOL newState;
    switch ([checkBox state]) {
        case NSOnState: newState = YES; break;
        case NSOffState:newState = NO; break;
    }
    // выполняем телодвижения только в случае изменения; это что бы два раза не добавить приложение в стартап лист
    if (oldState == newState)return;
    
    [PreferencesController setPrefRunAtLogin:newState];
    if (newState == YES) {
        [PreferencesController addAppAsLoginItem];
    } else {
        [PreferencesController deleteAppFromLoginItem];
    }
}
-(IBAction)changeTitleColor:(id)sender{
    NSColor *c = [titleColor color];
    [PreferencesController setPrefTitleColor:c];
    [titleAttributes setObject:c forKey:NSForegroundColorAttributeName];
    [[NSNotificationCenter defaultCenter] postNotificationName:DauWeeksMustRepaintNotification object:self];
}

-(NSDictionary*)titleAttributes{
    return [titleAttributes copy];
}


// два метода ниже полностью взяты отсюда - http://cocoatutorial.grapewave.com/tag/lssharedfilelist-h/

+(void) addAppAsLoginItem{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	// Create a reference to the shared file list.
    // We are adding it to the current user only.
    // If we want to add it all users, use
    // kLSSharedFileListGlobalLoginItems instead of
    //kLSSharedFileListSessionLoginItems
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
	if (loginItems) {
		//Insert an item to the list.
		LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems,
                                                                     kLSSharedFileListItemLast, NULL, NULL,
                                                                     url, NULL, NULL);
		if (item){
			CFRelease(item);
        }
	}
    
	CFRelease(loginItems);
}

+(void) deleteAppFromLoginItem{
	NSString * appPath = [[NSBundle mainBundle] bundlePath];
    
	// This will retrieve the path for the application
	// For example, /Applications/test.app
	CFURLRef url = (CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:appPath]);
    
	// Create a reference to the shared file list.
	LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL,
                                                            kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems) {
		UInt32 seedValue;
		//Retrieve the list of Login Items and cast them to
		// a NSArray so that it will be easier to iterate.
		NSArray  *loginItemsArray = (NSArray *)CFBridgingRelease(LSSharedFileListCopySnapshot(loginItems, &seedValue));
		
		for(int i = 0; i< [loginItemsArray count]; i++){
			LSSharedFileListItemRef itemRef = (LSSharedFileListItemRef)CFBridgingRetain([loginItemsArray
                                                                                         objectAtIndex:i]);
			//Resolve the item with URL
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
				NSString * urlPath = [(NSURL*)CFBridgingRelease(url) path];
				if ([urlPath compare:appPath] == NSOrderedSame){
					LSSharedFileListItemRemove(loginItems,itemRef);
				}
			}
		}
        //		[loginItemsArray release];
	}
}




@end
