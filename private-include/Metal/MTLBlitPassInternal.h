// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#ifndef _METAL_MTLBLITPASSINTERNAL_H_
#define _METAL_MTLBLITPASSINTERNAL_H_
#import <Metal/MTLBlitPass.h>
#if DARLING_METAL_ENABLED
#include <indium/blit-command-encoder.hpp>
@interface MTLBlitPassDescriptor (Internal)
- (Indium::BlitPassDescriptor)asIndiumDescriptor;
@end
#endif
#endif
