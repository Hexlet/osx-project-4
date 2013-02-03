//
//  Utils.m
//  iPitbul
//
//  Created by Mykhailo Oleksiuk on 12/11/12.
//  Copyright (c) 2012 Mykhailo Oleksiuk. All rights reserved.
//

#import "GenericUtils.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@implementation GenericUtils

+ (NSString *)applicationName {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
}

+ (NSString *)applicationNameWithVersion {
    return [NSString stringWithFormat:@"%@ %@", [self applicationName], [self appicationVersion]];
}

+ (NSString *)appicationVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (NSString *)device {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    if ([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"]) return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,2"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad2,3"]) return @"iPad 2";
    if ([platform isEqualToString:@"iPad3,1"]) return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"]) return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,3"]) return @"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"i386"]) return @"Simulator";
    if ([platform isEqualToString:@"x86_64"]) return @"Simulator";
    
    return platform;
}

+ (NSString *)iOSVersion {
    return [[UIDevice currentDevice] systemVersion];
}

+ (void)errorAlertWithTitle:(NSString *)title andMessage:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle: title
                                message: message
                               delegate: nil
                      cancelButtonTitle:NSLocalizedString(@"button.ok", nil)
                      otherButtonTitles:nil] show];
}

@end
