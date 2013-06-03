//
//  main.m
//  dylbert
//
//

#import <Foundation/Foundation.h>
#import "GBCommandLineParser.h"
#import "GBOptionsHelper.h"
#import "GBSettings.h"
#import "PatchHelper.h"

int main(int argc, char **argv)
{
@autoreleasepool
{
    GBSettings *settings = [GBSettings settingsWithName:@"Settings" parent:nil];
    NSMutableDictionary *settingsDict = [[NSMutableDictionary alloc] init];
    
    GBOptionsHelper *options = [[GBOptionsHelper alloc] init];
    options.applicationName = ^{return @"dylbert";};
    
    NSString *targetDesc = @"The .app whose binary you want to add a dylib to.";
    [options registerOption:'t' long:@"target" description:targetDesc
                      flags:GBValueRequired];
    
    NSString *dylibDesc = @"The dylib that will be added to the app.";
    [options registerOption:'d' long:@"dylib" description:dylibDesc
                      flags:GBValueRequired];
    
    [options registerOption:'h' long:@"help" description:@"Display help."
                      flags:GBValueNone];
    __block BOOL printHelp = FALSE;
    
    GBCommandLineParser *parser = [[GBCommandLineParser alloc] init];
    [options registerOptionsToCommandLineParser:parser];
    
    [parser parseOptionsWithArguments:argv count:argc block:^(GBParseFlags flags,
                                                              NSString *option,
                                                              id value, BOOL *stop)
    {
        switch (flags)
        {
            case GBParseFlagUnknownOption:
                printf("Unknown option: %s, see --help\n", option.UTF8String);
                break;
            case GBParseFlagMissingValue:
                printf("Missing value for %s\n", option.UTF8String);
            case GBParseFlagArgument:
                [settings addArgument:value];
                break;
            case GBParseFlagOption:
                if ([option isEqualToString:@"help"] || [option isEqualToString:@"h"]
                    || [option isEqualToString:@"?"])
                {
                    printHelp = TRUE;
                }
                                
                [settings setObject:value forKey:option];
                [settingsDict setObject:value forKey:option];
                break;
        }
    }];
    
    if (printHelp == TRUE || argc < 2)
    {
        [options printHelp];
        return 0;
    }
            
    NSString *dylibPath;
    NSString *targetPath;
    
    @try
    {
        dylibPath = [settingsDict valueForKey:@"dylib"];
        targetPath = [settingsDict valueForKey:@"target"];
    }
    @catch (NSException *exception)
    {
        printf("fail\n");
    }
    
    BOOL success = [PatchHelper insertDylib:dylibPath inTarget:targetPath];
    if (!success)
    {
        printf("fail\n");
    }
}
    
    return 0;
}

