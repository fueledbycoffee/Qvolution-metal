// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
// Negative compile control: every assignment must be rejected as read-only.
#import <Metal/MTLCounters.h>
void rejectCounterMutation(void) {
    MTLCommonCounterTimestamp = @"changed";
    MTLCommonCounterSetTimestamp = @"changed";
}
