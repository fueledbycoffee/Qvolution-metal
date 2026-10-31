// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#ifndef _METAL_MTLBLITPASS_H_
#define _METAL_MTLBLITPASS_H_
#import <Foundation/Foundation.h>
#import <Metal/MTLDefines.h>
#import <Metal/MTLCounterSampleBuffer.h>

METAL_DECLARATIONS_BEGIN

@protocol MTLCounterSampleBuffer;
@class MTLBlitPassSampleBufferAttachmentDescriptorArray;

MTL_EXPORT
@interface MTLBlitPassSampleBufferAttachmentDescriptor : NSObject <NSCopying>
@property(nullable, nonatomic, retain) id<MTLCounterSampleBuffer> sampleBuffer;
@property(nonatomic) NSUInteger startOfEncoderSampleIndex;
@property(nonatomic) NSUInteger endOfEncoderSampleIndex;
@end

MTL_EXPORT
@interface MTLBlitPassSampleBufferAttachmentDescriptorArray : NSObject
- (MTLBlitPassSampleBufferAttachmentDescriptor*)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(nullable MTLBlitPassSampleBufferAttachmentDescriptor*)attachment
  atIndexedSubscript:(NSUInteger)index;
@end

MTL_EXPORT
@interface MTLBlitPassDescriptor : NSObject <NSCopying>
+ (MTLBlitPassDescriptor*)blitPassDescriptor;
@property(readonly, nonatomic) MTLBlitPassSampleBufferAttachmentDescriptorArray* sampleBufferAttachments;
@end

METAL_DECLARATIONS_END
#endif
