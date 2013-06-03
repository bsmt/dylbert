//
//  PatchHelper.h
//  dylbert
//
//

#import <Cocoa/Cocoa.h>
@interface PatchHelper : NSObject

+(BOOL)insertDylib:(NSString *)dylibPath inTarget:(NSString *)targetPath;

@end
