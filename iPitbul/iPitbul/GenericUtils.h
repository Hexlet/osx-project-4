//
//  Utils.h
//  iPitbul
//
//  Created by Mykhailo Oleksiuk on 12/11/12.
//  Copyright (c) 2012 Mykhailo Oleksiuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GenericUtils : NSObject

@end

@interface GenericUtils(SystemUtils)
+ (NSString *)applicationName;
+ (NSString *)applicationNameWithVersion;
+ (NSString *)appicationVersion;
+ (NSString *)device;
+ (NSString *)iOSVersion;
@end

@interface GenericUtils(UIAlerts)
+ (void)errorAlertWithTitle:(NSString *)title andMessage:(NSString *)message;
@end