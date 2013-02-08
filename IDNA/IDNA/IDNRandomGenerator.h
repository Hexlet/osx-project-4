//
//  IDNRandomGenerator.h
//  IDNA
//
//  Created by Dmitriy Zhukov on 08.02.13.
//  Copyright (c) 2013 Dmitriy Zhukov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
extern NSString *const IDNRandomNumberNotification;

@interface IDNRandomGenerator : NSWindowController

@property NSInteger numberOfMouseMove;
@property unsigned int randomNumber;



@end
