//
//  PatchHelper.m
//  dylbert
//
//

#import "PatchHelper.h"
#import "Binary.h"
#import "Patcher.h"

@implementation PatchHelper

+(BOOL)insertDylib:(NSString *)dylibPath inTarget:(NSString *)targetPath
{
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *execPath;
    if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:targetPath]) // the target is an app, or some bundle
    {
        NSDictionary *appDict = [[NSBundle bundleWithPath:targetPath] infoDictionary];
        execPath = [targetPath stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"Contents/MacOS/%@",
                               appDict[@"CFBundleExecutable"]]];
        
        NSString *newDylibPath = [targetPath stringByAppendingPathComponent:
                                  [NSString stringWithFormat:@"Contents/MacOS/%@",
                                   [dylibPath lastPathComponent]]];
        
        [manager copyItemAtPath:dylibPath toPath:newDylibPath error:nil];
    }
    else // the target is a plain binary, nothing we have to do.
    {
        execPath = targetPath;
    }
        
    Binary *target = [[Binary alloc] initWithBinaryAtPath:execPath];
    Patcher *patch = [Patcher patcherWithBinary:target];
    BOOL success = [patch insertLoadDylibCommand:[dylibPath lastPathComponent]];
    return success;
}

@end
