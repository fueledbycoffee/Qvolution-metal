// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#ifndef _METAL_MTLCOUNTERS_H_
#define _METAL_MTLCOUNTERS_H_
#import <Foundation/Foundation.h>
#import <Metal/MTLDefines.h>

METAL_DECLARATIONS_BEGIN

@protocol MTLCounter <NSObject>
@property(readonly, nonnull) NSString* name;
@end

@protocol MTLCounterSet <NSObject>
@property(readonly, nonnull) NSString* name;
@property(readonly, nonnull) NSArray<id<MTLCounter>>* counters;
@end

typedef struct __attribute__((packed)) {
	uint64_t timestamp;
} MTLCounterResultTimestamp;

#define MTLCounterErrorValue NSUIntegerMax

typedef NS_ENUM(NSInteger, MTLCounterSampleBufferError) {
	MTLCounterSampleBufferErrorOutOfMemory = 0,
	MTLCounterSampleBufferErrorInvalid = 1,
	MTLCounterSampleBufferErrorInternal = 2,
};

MTL_EXPORT MTL_EXTERN NSString* const MTLCounterErrorDomain;

typedef NSString* const MTLCommonCounter;
typedef NSString* const MTLCommonCounterSet;

MTL_EXPORT MTL_EXTERN MTLCommonCounter MTLCommonCounterTimestamp;
MTL_EXPORT MTL_EXTERN MTLCommonCounter MTLCommonCounterTessellationInputPatches;
MTL_EXPORT MTL_EXTERN MTLCommonCounter MTLCommonCounterVertexInvocations;
MTL_EXPORT MTL_EXTERN MTLCommonCounter MTLCommonCounterPostTessellationVertexInvocations;
MTL_EXPORT MTL_EXTERN MTLCommonCounter MTLCommonCounterClipperInvocations;
MTL_EXPORT MTL_EXTERN MTLCommonCounter MTLCommonCounterClipperPrimitivesOut;
MTL_EXPORT MTL_EXTERN MTLCommonCounter MTLCommonCounterFragmentInvocations;
MTL_EXPORT MTL_EXTERN MTLCommonCounter MTLCommonCounterFragmentsPassed;
MTL_EXPORT MTL_EXTERN MTLCommonCounter MTLCommonCounterComputeKernelInvocations;
MTL_EXPORT MTL_EXTERN MTLCommonCounter MTLCommonCounterTotalCycles;
MTL_EXPORT MTL_EXTERN MTLCommonCounter MTLCommonCounterVertexCycles;
MTL_EXPORT MTL_EXTERN MTLCommonCounter MTLCommonCounterTessellationCycles;
MTL_EXPORT MTL_EXTERN MTLCommonCounter MTLCommonCounterPostTessellationVertexCycles;
MTL_EXPORT MTL_EXTERN MTLCommonCounter MTLCommonCounterFragmentCycles;
MTL_EXPORT MTL_EXTERN MTLCommonCounter MTLCommonCounterRenderTargetWriteCycles;

MTL_EXPORT MTL_EXTERN MTLCommonCounterSet MTLCommonCounterSetTimestamp;
MTL_EXPORT MTL_EXTERN MTLCommonCounterSet MTLCommonCounterSetStageUtilization;
MTL_EXPORT MTL_EXTERN MTLCommonCounterSet MTLCommonCounterSetStatistic;

METAL_DECLARATIONS_END
#endif
