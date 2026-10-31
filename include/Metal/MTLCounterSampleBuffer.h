// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#ifndef _METAL_MTLCOUNTERSAMPLEBUFFER_H_
#define _METAL_MTLCOUNTERSAMPLEBUFFER_H_

#import <Foundation/Foundation.h>

#import <Metal/MTLDefines.h>
#import <Metal/MTLCounters.h>
#import <Metal/MTLResource.h>

@protocol MTLCounterSet;

#define MTLCounterDontSample NSUIntegerMax

METAL_DECLARATIONS_BEGIN

@protocol MTLDevice;

@protocol MTLCounterSampleBuffer <NSObject>
@property(readonly, nonnull) id<MTLDevice> device;
@property(readonly, nullable) NSString* label;
@property(readonly) NSUInteger sampleCount;
- (nullable NSData*)resolveCounterRange:(NSRange)range;
@end

MTL_EXPORT
@interface MTLCounterSampleBufferDescriptor : NSObject <NSCopying>

@property(nullable, nonatomic, copy) NSString* label;
@property(nullable, nonatomic, retain) id<MTLCounterSet> counterSet;
@property(nonatomic) MTLStorageMode storageMode;
@property(nonatomic) NSUInteger sampleCount;

@end

METAL_DECLARATIONS_END

#endif // _METAL_MTLCOUNTERSAMPLEBUFFER_H_
