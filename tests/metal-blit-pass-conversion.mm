// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#import <Metal/MTLBlitPassInternal.h>
#include <assert.h>
#include <stdio.h>
#ifdef NDEBUG
#error Assertions required
#endif
int main(void) {
    @autoreleasepool {
        MTLBlitPassDescriptor *pass=[MTLBlitPassDescriptor blitPassDescriptor];
        assert([pass asIndiumDescriptor].sampleBufferAttachments.empty());
        pass.sampleBufferAttachments[2].startOfEncoderSampleIndex=17;
        assert([pass asIndiumDescriptor].sampleBufferAttachments.empty());
        pass.sampleBufferAttachments[2].sampleBuffer=(id)[[[NSObject alloc] init] autorelease];
        BOOL rejected=NO;
        @try { (void)[pass asIndiumDescriptor]; }
        @catch (NSException *exception) {
            rejected=[exception.name isEqualToString:NSInternalInconsistencyException]
                && [exception.reason rangeOfString:@"counter sampling is unsupported"].location != NSNotFound;
        }
        assert(rejected);
        pass.sampleBufferAttachments[2]=nil;
        assert([pass asIndiumDescriptor].sampleBufferAttachments.empty());
        puts("PASS: default blit pass bridge and explicit unsupported counter sampling");
    }
}
