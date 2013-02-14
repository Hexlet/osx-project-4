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
        _vm_name = @"BOOTCAMP_VM";
        _vmdk_file_name = @"bootcampvm";
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
    for (NSUInteger i = 0; i < volumes.count; i++) {
        Volume *v = [volumes objectAtIndex:i];
        if ([[v.label uppercaseString] isEqualToString:@"BOOTCAMP"]) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:i];
            [_volumesTableView selectRowIndexes:indexSet byExtendingSelection:NO];
            break;
        }
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
            NSString *vbm_create = [NSString stringWithFormat:@"sudo VBoxManage internalcommands createrawvmdk -rawdisk /dev/disk%@ -filename %@.vmdk -partitions %@;", disk_s[0], _vmdk_file_name, disk_s[1]];
            NSString *chmod_chown_vmdk = [NSString stringWithFormat:@"sudo chmod a+rw %@/*.vmdk; sudo chown %@ %@/*.vmdk", bootcamp_vm_dir, NSUserName(), bootcamp_vm_dir];
            
            //Assemble AppleScript
            NSMutableString *create_vmdk_source = [[NSMutableString alloc] init];
            [create_vmdk_source appendString:@"do shell script \""];
            [create_vmdk_source appendString:chmod_dev];
            [create_vmdk_source appendString:cd_vm_dir];
            [create_vmdk_source appendString:vbm_create];
            [create_vmdk_source appendString:chmod_chown_vmdk];
            [create_vmdk_source appendString:@"\" with administrator privileges"];
            
            //Print details to console
            [self appendTextToDetails:[NSString stringWithFormat:NSLocalizedString(@"RUNNING_SCRIPT_MSG", "RUNNING_SCRIPT_MSG"), chmod_dev]];
            [self appendTextToDetails:[NSString stringWithFormat:NSLocalizedString(@"RUNNING_SCRIPT_MSG", "RUNNING_SCRIPT_MSG"), cd_vm_dir]];
            [self appendTextToDetails:[NSString stringWithFormat:NSLocalizedString(@"RUNNING_SCRIPT_MSG", "RUNNING_SCRIPT_MSG"), vbm_create]];
            [self appendTextToDetails:[NSString stringWithFormat:NSLocalizedString(@"RUNNING_SCRIPT_MSG", "RUNNING_SCRIPT_MSG"), chmod_chown_vmdk]];
            
            //Execute AppleScript
            NSAppleScript *create_vmdk_script = [[NSAppleScript alloc] initWithSource:create_vmdk_source];
            NSDictionary *errorDict;
            [create_vmdk_script executeAndReturnError:&errorDict];
            [self appendTextToDetails:NSLocalizedString(@"DONE_MSG", "DONE_MSG")];

            //Fix sticky bits
            NSString *partition_table_file = [NSString stringWithFormat:@"%@/%@-pt.vmdk", bootcamp_vm_dir, _vmdk_file_name];
            
            NSData *bootcamp_pt_data = [NSData dataWithContentsOfFile:partition_table_file];
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
            
            NSMutableData *fixed_partition_table = [NSMutableData data];
            for (NSUInteger idx = 0; idx+2 <= string.length; idx+=2) {
                NSRange range = NSMakeRange(idx, 2);
                NSString *hexStr = [string substringWithRange:range];
                NSScanner *scanner = [NSScanner scannerWithString:hexStr];
                unsigned int intValue;
                [scanner scanHexInt:&intValue];
                [fixed_partition_table appendBytes:&intValue length:1];
            }
            [fixed_partition_table writeToFile:partition_table_file atomically:YES]; //TODO handle status
            
            // create a new VM
            NSString *vbm_createvm = [NSString stringWithFormat:@"VBoxManage createvm --name \\\"%@\\\" --ostype \\\"WindowsXP\\\" --register --basefolder %@;", _vm_name, bootcamp_vm_dir];
            NSString *vbm_modifyvm = [NSString stringWithFormat:@"VBoxManage modifyvm \\\"%@\\\" --memory 1024 --vram 64 --ioapic on --hwvirtex on --chipset piix3 --nestedpaging on --boot1 disk --boot2 none --boot3 none --boot4 none --rtcuseutc on --clipboard bidirectional --accelerate2dvideo on --audio coreaudio --audiocontroller ac97;", _vm_name];
            NSString *vbm_storagectl = [NSString stringWithFormat:@"VBoxManage storagectl \\\"%@\\\" --name \\\"IDE Controller\\\" --add ide --controller ICH6;", _vm_name];
            NSString *vbm_storageattach_hd = [NSString stringWithFormat:@"VBoxManage storageattach \\\"%@\\\" --storagectl \\\"IDE Controller\\\" --port 0 --device 0 --type hdd --medium %@/%@.vmdk;", _vm_name, bootcamp_vm_dir, _vmdk_file_name];
            NSString *vbm_storageattach_addons = [NSString stringWithFormat:@"VBoxManage storageattach \\\"%@\\\" --storagectl \\\"IDE Controller\\\" --port 1 --device 0 --type dvddrive --medium /Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso", _vm_name];
            
            //Assemble AppleScript
            NSMutableString *create_vm_source = [[NSMutableString alloc] init];
            [create_vm_source appendString:@"do shell script \""];
            [create_vm_source appendString:vbm_createvm];
            [create_vm_source appendString:vbm_modifyvm];
            [create_vm_source appendString:vbm_storagectl];
            [create_vm_source appendString:vbm_storageattach_hd];
            [create_vm_source appendString:vbm_storageattach_addons];
            [create_vm_source appendString:@"\""];
            
            //Print details to console
            [self appendTextToDetails:[NSString stringWithFormat:NSLocalizedString(@"RUNNING_SCRIPT_MSG", "RUNNING_SCRIPT_MSG"), vbm_createvm]];
            [self appendTextToDetails:[NSString stringWithFormat:NSLocalizedString(@"RUNNING_SCRIPT_MSG", "RUNNING_SCRIPT_MSG"), vbm_modifyvm]];
            [self appendTextToDetails:[NSString stringWithFormat:NSLocalizedString(@"RUNNING_SCRIPT_MSG", "RUNNING_SCRIPT_MSG"), vbm_storagectl]];
            [self appendTextToDetails:[NSString stringWithFormat:NSLocalizedString(@"RUNNING_SCRIPT_MSG", "RUNNING_SCRIPT_MSG"), vbm_storageattach_hd]];
            [self appendTextToDetails:[NSString stringWithFormat:NSLocalizedString(@"RUNNING_SCRIPT_MSG", "RUNNING_SCRIPT_MSG"), vbm_storageattach_addons]];
            
            //Execute AppleScript
            NSAppleScript *create_vm_script = [[NSAppleScript alloc] initWithSource:create_vm_source];
            [create_vm_script executeAndReturnError:&errorDict];
                
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
