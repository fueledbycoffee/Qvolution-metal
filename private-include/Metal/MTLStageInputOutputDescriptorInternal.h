// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#ifndef _METAL_MTLSTAGEINPUTOUTPUTDESCRIPTORINTERNAL_H_
#define _METAL_MTLSTAGEINPUTOUTPUTDESCRIPTORINTERNAL_H_
#import <Metal/MTLStageInputOutputDescriptor.h>
#if DARLING_METAL_ENABLED
#include <indium/compute-pipeline.hpp>
@interface MTLAttributeDescriptorArray (Internal)
- (std::unordered_map<size_t, Indium::AttributeDescriptor>)asIndiumDescriptors;
@end
@interface MTLBufferLayoutDescriptorArray (Internal)
- (std::unordered_map<size_t, Indium::BufferLayoutDescriptor>)asIndiumDescriptors;
@end
@interface MTLStageInputOutputDescriptor (Internal)
- (Indium::StageInputOutputDescriptor)asIndiumDescriptor;
@end
#endif
#endif
