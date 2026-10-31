// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#import <Foundation/Foundation.h>
#include <assert.h>
#include <string.h>

static void mutateString(NSMutableString* target, NSUInteger operation) {
    switch (operation) {
        case 0: [target appendString:@"#"]; break;
        case 1: [target setString:@"#"]; break;
        case 2: [target replaceCharactersInRange:NSMakeRange(0,1) withString:@"!"]; break;
        default: assert(0);
    }
}

static BOOL rejectsStringMutation(NSString* value, NSUInteger operation) {
    @try { mutateString((NSMutableString*)value, operation); }
    @catch(NSException* exception) {
        return [exception.name isEqualToString:NSInvalidArgumentException]
            || [exception.name isEqualToString:NSInternalInconsistencyException];
    }
    return NO;
}

static NSData* snapshotStringBytes(NSString* value) {
    return [NSData dataWithBytes:value.UTF8String length:strlen(value.UTF8String)];
}

static void assertMutableCopyChanges(NSString* value, NSUInteger operation) {
    NSData* original=snapshotStringBytes(value);
    NSMutableString* mutable=[value mutableCopy];
    mutateString(mutable, operation);
    assert(![snapshotStringBytes(mutable) isEqualToData:original]);
    assert([snapshotStringBytes(value) isEqualToData:original]);
    [mutable release];
}
