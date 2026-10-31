// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#import <Metal/MTLComputeCommandEncoder.h>
#include <assert.h>
#include <stdio.h>
#ifdef NDEBUG
#error Assertions required
#endif
int main(void) {
    @autoreleasepool {
        puts("ENTER counter sentinel regression"); fflush(stdout);
        assert(MTLCounterDontSample == NSUIntegerMax);
        assert(MTLCounterDontSample != 0);
        MTLComputePassSampleBufferAttachmentDescriptor *attachment=[MTLComputePassSampleBufferAttachmentDescriptor new];
        assert(attachment.sampleBuffer == nil);
        assert(attachment.startOfEncoderSampleIndex == MTLCounterDontSample);
        assert(attachment.endOfEncoderSampleIndex == MTLCounterDontSample);
        attachment.startOfEncoderSampleIndex=0;
        attachment.endOfEncoderSampleIndex=MTLCounterDontSample;
        MTLComputePassSampleBufferAttachmentDescriptor *copy=[attachment copy];
        attachment.startOfEncoderSampleIndex=4;
        assert(copy.startOfEncoderSampleIndex == 0 && copy.endOfEncoderSampleIndex == MTLCounterDontSample);
        [copy release]; [attachment release];
        puts("PASS: DontSample sentinel differs from sample zero; compute indices copy independently");
    }
}
