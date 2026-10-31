// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#ifndef _METAL_MTLCOUNTERSAMPLEBUFFERINTERNAL_H_
#define _METAL_MTLCOUNTERSAMPLEBUFFERINTERNAL_H_
#import <Metal/MTLCounterSampleBuffer.h>
#if DARLING_METAL_ENABLED
#include <indium/counter.hpp>
@interface MTLTimestampCounterSetInternal : NSObject <MTLCounterSet>
@property(readonly) id<MTLDevice> device;
- (instancetype)initWithDevice:(id<MTLDevice>)device;
@end
@interface MTLCounterSampleBufferInternal : NSObject <MTLCounterSampleBuffer>
@property(readonly) std::shared_ptr<Indium::CounterSampleBuffer> buffer;
- (instancetype)initWithBuffer:(std::shared_ptr<Indium::CounterSampleBuffer>)buffer
                        device:(id<MTLDevice>)device label:(NSString*)label;
@end
#endif
#endif
