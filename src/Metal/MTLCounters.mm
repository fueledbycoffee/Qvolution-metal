// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#import <Metal/MTLCounters.h>

// Opaque project identity tokens. Native raw strings are not established by
// Apple's public contracts; these names do not advertise any supported counters.
MTLCommonCounter MTLCommonCounterTimestamp = @"MTLCommonCounterTimestamp";
MTLCommonCounter MTLCommonCounterTessellationInputPatches = @"MTLCommonCounterTessellationInputPatches";
MTLCommonCounter MTLCommonCounterVertexInvocations = @"MTLCommonCounterVertexInvocations";
MTLCommonCounter MTLCommonCounterPostTessellationVertexInvocations = @"MTLCommonCounterPostTessellationVertexInvocations";
MTLCommonCounter MTLCommonCounterClipperInvocations = @"MTLCommonCounterClipperInvocations";
MTLCommonCounter MTLCommonCounterClipperPrimitivesOut = @"MTLCommonCounterClipperPrimitivesOut";
MTLCommonCounter MTLCommonCounterFragmentInvocations = @"MTLCommonCounterFragmentInvocations";
MTLCommonCounter MTLCommonCounterFragmentsPassed = @"MTLCommonCounterFragmentsPassed";
MTLCommonCounter MTLCommonCounterComputeKernelInvocations = @"MTLCommonCounterComputeKernelInvocations";
MTLCommonCounter MTLCommonCounterTotalCycles = @"MTLCommonCounterTotalCycles";
MTLCommonCounter MTLCommonCounterVertexCycles = @"MTLCommonCounterVertexCycles";
MTLCommonCounter MTLCommonCounterTessellationCycles = @"MTLCommonCounterTessellationCycles";
MTLCommonCounter MTLCommonCounterPostTessellationVertexCycles = @"MTLCommonCounterPostTessellationVertexCycles";
MTLCommonCounter MTLCommonCounterFragmentCycles = @"MTLCommonCounterFragmentCycles";
MTLCommonCounter MTLCommonCounterRenderTargetWriteCycles = @"MTLCommonCounterRenderTargetWriteCycles";

MTLCommonCounterSet MTLCommonCounterSetTimestamp = @"MTLCommonCounterSetTimestamp";
MTLCommonCounterSet MTLCommonCounterSetStageUtilization = @"MTLCommonCounterSetStageUtilization";
MTLCommonCounterSet MTLCommonCounterSetStatistic = @"MTLCommonCounterSetStatistic";
