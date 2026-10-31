// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#include <assert.h>
#include <stdio.h>
#ifdef NDEBUG
#error Assertions required
#endif
// Typed public shapes let this same fixture link against the pre-change library.
@protocol BlitAttachmentShape <NSObject, NSCopying>
@property(nonatomic, retain) id sampleBuffer;
@property NSUInteger startOfEncoderSampleIndex;
@property NSUInteger endOfEncoderSampleIndex;
@end
@protocol BlitArrayShape <NSObject>
- (id<BlitAttachmentShape>)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(id<BlitAttachmentShape>)attachment atIndexedSubscript:(NSUInteger)index;
@end
@protocol BlitPassShape <NSObject, NSCopying>
+ (instancetype)blitPassDescriptor;
@property(readonly) id<BlitArrayShape> sampleBufferAttachments;
@end
static NSUInteger destroyed;
@interface OwnedBuffer : NSObject @end
@implementation OwnedBuffer
- (void)dealloc { destroyed++; [super dealloc]; }
@end
static BOOL rejects(id<BlitArrayShape> array, NSUInteger index, BOOL write) {
    @try {
        if (write) [array setObject:nil atIndexedSubscript:index];
        else [array objectAtIndexedSubscript:index];
    } @catch (NSException *exception) {
        return [exception.name isEqualToString:NSRangeException];
    }
    return NO;
}
int main(void) {
    @autoreleasepool {
        setbuf(stdout,NULL); puts("ENTER Metal blit-pass descriptor fixture");
        assert(NSClassFromString(@"MTLCommandBufferDescriptor") != Nil);
        for (NSString *name in @[@"MTLBlitPassDescriptor", @"MTLBlitPassSampleBufferAttachmentDescriptor", @"MTLBlitPassSampleBufferAttachmentDescriptorArray"]) {
            printf("CLASS %s\n", name.UTF8String);
            assert(NSClassFromString(name) != Nil);
        }
        @autoreleasepool {
        id<BlitPassShape> pass=[(id)NSClassFromString(@"MTLBlitPassDescriptor") blitPassDescriptor];
        assert(pass && pass.sampleBufferAttachments);
        id<BlitAttachmentShape> original=[pass.sampleBufferAttachments objectAtIndexedSubscript:0];
        assert(original.sampleBuffer == nil);
        assert(original.startOfEncoderSampleIndex == MTLCounterDontSample && original.endOfEncoderSampleIndex == MTLCounterDontSample);
        original.startOfEncoderSampleIndex=7; original.endOfEncoderSampleIndex=NSUIntegerMax;
        id buffer=[[OwnedBuffer alloc] init]; original.sampleBuffer=buffer; [buffer release];
        assert(destroyed == 0);
        id<BlitAttachmentShape> attachmentCopy=[original copyWithZone:NULL];
        assert(attachmentCopy != original && attachmentCopy.sampleBuffer == original.sampleBuffer);
        assert(attachmentCopy.startOfEncoderSampleIndex == 7 && attachmentCopy.endOfEncoderSampleIndex == NSUIntegerMax);
        id<BlitPassShape> copy=[pass copyWithZone:NULL];
        id<BlitAttachmentShape> copied=[copy.sampleBufferAttachments objectAtIndexedSubscript:0];
        assert(copy != pass && copy.sampleBufferAttachments != pass.sampleBufferAttachments && copied != original);
        assert(copied.sampleBuffer == original.sampleBuffer && copied.startOfEncoderSampleIndex == 7 && copied.endOfEncoderSampleIndex == NSUIntegerMax);
        original.startOfEncoderSampleIndex=9; assert(copied.startOfEncoderSampleIndex == 7);
        original.sampleBuffer=nil; assert(destroyed == 0);
        assert([pass.sampleBufferAttachments objectAtIndexedSubscript:3]);
        assert(rejects(pass.sampleBufferAttachments,4,NO) && rejects(pass.sampleBufferAttachments,4,YES));
        assert(rejects(pass.sampleBufferAttachments,NSUIntegerMax,NO));
        BOOL wrong=NO;
        @try { [pass.sampleBufferAttachments setObject:(id)@"wrong" atIndexedSubscript:1]; }
        @catch (NSException *exception) { wrong=[exception.name isEqualToString:NSInvalidArgumentException]; }
        assert(wrong);
        id<BlitAttachmentShape> assigned=[(id)NSClassFromString(@"MTLBlitPassSampleBufferAttachmentDescriptor") new];
        assigned.startOfEncoderSampleIndex=13;
        [pass.sampleBufferAttachments setObject:assigned atIndexedSubscript:2]; [assigned release];
        assert([pass.sampleBufferAttachments objectAtIndexedSubscript:2].startOfEncoderSampleIndex == 13);
        [pass.sampleBufferAttachments setObject:nil atIndexedSubscript:2];
        assert([pass.sampleBufferAttachments objectAtIndexedSubscript:2].sampleBuffer == nil);
        [copy release]; assert(destroyed == 0);
        [attachmentCopy release];
        }
        assert(destroyed == 1);
        puts("PASS: blit-pass configuration, retained resources, independent copies and bounds");
    }
    return 0;
}
