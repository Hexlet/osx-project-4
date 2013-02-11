//
//  Document.m
//  VBoxCamp
//
//  Created by Dmitriy Zavorokhin on 12/26/12.
//  Copyright (c) 2012 goodman116@gmail.com. All rights reserved.
//

#import "Document.h"
#import "Volume.h"

@implementation Document

- (id)init
{
    self = [super init];
    if (self) {
        volumes = [self volumesInfo];
    }
    return self;
}

- (NSArray *)volumesInfo {
    
    // Get a list of mounted non-hidden volumes
    NSArray *volumeURLs = [[NSFileManager defaultManager] mountedVolumeURLsIncludingResourceValuesForKeys:nil options:NSVolumeEnumerationSkipHiddenVolumes];
    NSUInteger size = [volumeURLs count];
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:size];
    DASessionRef session = DASessionCreate(kCFAllocatorDefault);
    
    for (NSURL *url in volumeURLs) {
        NSString *label = [url lastPathComponent];
        // Escape root mount point 
        if (![label isEqualToString:@"/"]) {
            // Create DADisk for the volume
            DADiskRef volumeDisk = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, (__bridge CFURLRef)url);
            
            // Filter out files/directories that aren't volumes
            if (volumeDisk) {
                Volume *v = [[Volume alloc] init];
                // Get disk description
                NSDictionary *description = (__bridge_transfer NSDictionary *)DADiskCopyDescription(volumeDisk);
                // Add label
                [v setLabel:label];
                // Add mount point
                [v setMountPoint:[url path]];
                // Add BSD disk identifier in format disc#s#
                [v setBsdId:[description objectForKey: (__bridge id)kDADiskDescriptionMediaBSDNameKey]];
                [result addObject:v];
                CFRelease(volumeDisk);
            }
        }
    }
    CFRelease(session);
    return result;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    NSInteger bcIndex = -1;
    NSUInteger i = 0;
    for (Volume *v in volumes) {
        if ([[v.label uppercaseString] isEqualToString:@"BOOTCAMP"]) {
            bcIndex = i;
        }
        i++;
    }
    if (bcIndex != -1) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:bcIndex];
        [_volumesTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    }
    if (volumes != nil) {
        [self appendTextToDetails: NSLocalizedString(@"GETTING_INFO_MSG", "GETTING_INFO_MSG")];
    }
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return YES;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
//    NSLog(@"Calling numberOfRowsInTableView: %ld", [volumes count]);
    volumes = [self volumesInfo];
    return [volumes count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
//    NSLog(@"Returning %@ to be displayed", [volumes objectAtIndex:rowIndex]);
    return [volumes objectAtIndex:rowIndex];
}

- (IBAction)refresh:(id)sender {
    volumes = [self volumesInfo];
    [_volumesTableView reloadData]; // TODO fix it
}

- (IBAction)createBootcampVM:(id)sender {
    if ([_volumesTableView selectedRow] != -1) {
        Volume *v = [volumes objectAtIndex:[_volumesTableView selectedRow]];
        
        //Show system dialog to choose VM files location
        NSOpenPanel *openDlg = [NSOpenPanel openPanel];
        [openDlg setCanChooseFiles:NO];
        [openDlg setCanChooseDirectories:YES];
        [openDlg setAllowsMultipleSelection:NO];
        [openDlg setTitle:NSLocalizedString(@"SELECT_PATH_MSG", "SELECT_PATH_MSG")];
        [openDlg setPrompt:NSLocalizedString(@"SELECT_BTN", "SELECT_BTN")];
        if ([openDlg runModal] == NSOKButton) {
            NSString *bootcamp_vm_dir = [[openDlg URL] path];
            NSString *chmod_dev = [NSString stringWithFormat:@"sudo chmod a+rw /dev/%@;", v.bsdId];
            NSString *cd_vm_dir = [NSString stringWithFormat:@"cd %@;", bootcamp_vm_dir];
            NSRange range = [v.bsdId rangeOfString:@"disk"];
            NSArray *disk_s = [[v.bsdId substringFromIndex:NSMaxRange(range)] componentsSeparatedByString:@"s"];
            NSString *vbmanage_create = [NSString stringWithFormat:@"sudo VBoxManage internalcommands createrawvmdk -rawdisk /dev/disk%@ -filename bootcamp.vmdk -partitions %@;", disk_s[0], disk_s[1]];
            NSString *chmod_chown_vmdk = [NSString stringWithFormat:@"sudo chmod a+rw %@/*.vmdk; sudo chown %@ %@/*.vmdk", bootcamp_vm_dir, NSUserName(), bootcamp_vm_dir];
            
            //Assemble AppleScript
            NSMutableString *create_vmdk_source = [[NSMutableString alloc] init];
            [create_vmdk_source appendString:@"do shell script \""];
            [create_vmdk_source appendString:chmod_dev];
            [create_vmdk_source appendString:cd_vm_dir];
            [create_vmdk_source appendString:vbmanage_create];
            [create_vmdk_source appendString:chmod_chown_vmdk];
            [create_vmdk_source appendString:@"\" with administrator privileges"];
            
            //Print details to console
            [self appendTextToDetails:[NSString stringWithFormat:NSLocalizedString(@"RUNNING_SCRIPT_MSG", "RUNNING_SCRIPT_MSG"), chmod_dev]];
            [self appendTextToDetails:[NSString stringWithFormat:NSLocalizedString(@"RUNNING_SCRIPT_MSG", "RUNNING_SCRIPT_MSG"), cd_vm_dir]];
            [self appendTextToDetails:[NSString stringWithFormat:NSLocalizedString(@"RUNNING_SCRIPT_MSG", "RUNNING_SCRIPT_MSG"), vbmanage_create]];
            [self appendTextToDetails:[NSString stringWithFormat:NSLocalizedString(@"RUNNING_SCRIPT_MSG", "RUNNING_SCRIPT_MSG"), chmod_chown_vmdk]];
            
            //Execute AppleScript
            NSAppleScript *create_vmdk_script = [[NSAppleScript alloc] initWithSource:create_vmdk_source];
            NSDictionary *errorDict;
            [create_vmdk_script executeAndReturnError:&errorDict];
            [self appendTextToDetails:NSLocalizedString(@"DONE_MSG", "DONE_MSG")];

            //Fix sticky bits
            NSString *path = [NSString stringWithFormat:@"%@/bootcamp-pt.vmdk", bootcamp_vm_dir];
            NSLog(@"Path: %@", path);
            
            NSData *bootcamp_pt_data = [NSData dataWithContentsOfFile:path];
            NSUInteger dataLength = [bootcamp_pt_data length];
            NSMutableString *string = [NSMutableString stringWithCapacity:dataLength*2];
            const unsigned char *dataBytes = [bootcamp_pt_data bytes];
            for (NSUInteger idx = 0; idx < dataLength; ++idx) {
                [string appendFormat:@"%02x", dataBytes[idx]];
            }

            NSUInteger offset = 446; // byte of partition records start in MBR
            for (NSUInteger i = 0; i < [disk_s[1] intValue]-1; i++) {
                [string replaceCharactersInRange:NSMakeRange((offset + 16*i + 4)*2, 2) withString:@"2d"]; // change the fifth byte of each 16-bytes partition record before BOOTCAMP's partition record
            }
            
            NSMutableData *data = [NSMutableData data];
            for (NSUInteger idx = 0; idx+2 <= string.length; idx+=2) {
                NSRange range = NSMakeRange(idx, 2);
                NSString *hexStr = [string substringWithRange:range];
                NSScanner *scanner = [NSScanner scannerWithString:hexStr];
                unsigned int intValue;
                [scanner scanHexInt:&intValue];
                [data appendBytes:&intValue length:1];
            }
            [data writeToFile:path atomically:YES]; //TODO handle status
            
            // create a new VM
            
            NSMutableString *create_vm_source = [[NSMutableString alloc] init];
            [create_vm_source appendString:@"do shell script \""];
            // TODO write script
            
        }
    }
}


-(void)appendTextToDetails:(NSString *)aString {
    NSMutableString *ms = [NSMutableString stringWithString:[_detailsTextView string]];
    [ms appendString:aString];
    [ms appendString:@"\n"];
    [_detailsTextView setString:ms];
}

@end
