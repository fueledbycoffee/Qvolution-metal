// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#import <Metal/Metal.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>
#ifdef NDEBUG
#error Assertions required
#endif
int main(void) {
    @autoreleasepool {
        id<MTLDevice> device=MTLCreateSystemDefaultDevice();
        if (device == nil) { puts("SKIP: no real Metal device; blit execution unverified"); return 77; }
        id<MTLCommandQueue> queue=[device newCommandQueue]; assert(queue);
        unsigned char input[256];
        for (NSUInteger i=0;i<sizeof(input);i++) input[i]=(unsigned char)(i^0x5a);
        id<MTLBuffer> source=[device newBufferWithBytes:input length:sizeof(input) options:MTLResourceStorageModeShared];
        id<MTLBuffer> target=[device newBufferWithLength:sizeof(input) options:MTLResourceStorageModeShared];
        assert(source && target); memset(target.contents,0,sizeof(input));
        MTLBlitPassDescriptor *pass=[MTLBlitPassDescriptor blitPassDescriptor];
        id<MTLCommandBuffer> command=[queue commandBuffer]; assert(command);
        id<MTLBlitCommandEncoder> encoder=[command blitCommandEncoderWithDescriptor:pass]; assert(encoder);
        [encoder copyFromBuffer:source sourceOffset:0 toBuffer:target destinationOffset:0 size:sizeof(input)];
        [encoder endEncoding]; [command commit]; [command waitUntilCompleted];
        assert(memcmp(target.contents,input,sizeof(input))==0);
        command=[queue commandBuffer];
        encoder=[command blitCommandEncoderWithDescriptor:pass]; assert(encoder);
        [encoder fillBuffer:target range:NSMakeRange(0,sizeof(input)) value:0xc3];
        [encoder endEncoding]; [command commit]; [command waitUntilCompleted];
        for (NSUInteger i=0;i<sizeof(input);i++) assert(((unsigned char*)target.contents)[i]==0xc3);
        BOOL rejected=NO;
        pass.sampleBufferAttachments[0].sampleBuffer=(id)[[[NSObject alloc] init] autorelease];
        command=[queue commandBuffer];
        @try { [command blitCommandEncoderWithDescriptor:pass]; }
        @catch(NSException *exception) { rejected=[exception.name isEqualToString:NSInternalInconsistencyException]; }
        assert(rejected);
        pass.sampleBufferAttachments[0]=nil;
        encoder=[command blitCommandEncoderWithDescriptor:pass]; assert(encoder);
        [encoder endEncoding]; [command commit]; [command waitUntilCompleted];
        [target release]; [source release]; [queue release]; [device release];
        puts("PASS: descriptor-created real blit encoder copies and fills bytes; sampling rejected");
    }
}
