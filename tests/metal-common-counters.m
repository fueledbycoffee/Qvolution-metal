// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "metal-string-immutability.h"
#include <assert.h>
#include <stdio.h>
#ifdef NDEBUG
#error Assertions required
#endif
#if __has_include(<Metal/MTLCounters.h>) && !defined(COUNTER_WEAK_CONTROL)
#import <Metal/MTLCounters.h>
#else
// Public shapes permit a frozen strong-link BEFORE and a weak missing-export control.
typedef NSString* const MTLCommonCounter;
typedef NSString* const MTLCommonCounterSet;
#ifdef COUNTER_WEAK_CONTROL
#define COUNTER_IMPORT __attribute__((weak_import))
#else
#define COUNTER_IMPORT
#endif
#define COUNTER(name) extern MTLCommonCounter name COUNTER_IMPORT
#define COUNTER_SET(name) extern MTLCommonCounterSet name COUNTER_IMPORT
COUNTER(MTLCommonCounterTimestamp);
COUNTER(MTLCommonCounterTessellationInputPatches);
COUNTER(MTLCommonCounterVertexInvocations);
COUNTER(MTLCommonCounterPostTessellationVertexInvocations);
COUNTER(MTLCommonCounterClipperInvocations);
COUNTER(MTLCommonCounterClipperPrimitivesOut);
COUNTER(MTLCommonCounterFragmentInvocations);
COUNTER(MTLCommonCounterFragmentsPassed);
COUNTER(MTLCommonCounterComputeKernelInvocations);
COUNTER(MTLCommonCounterTotalCycles);
COUNTER(MTLCommonCounterVertexCycles);
COUNTER(MTLCommonCounterTessellationCycles);
COUNTER(MTLCommonCounterPostTessellationVertexCycles);
COUNTER(MTLCommonCounterFragmentCycles);
COUNTER(MTLCommonCounterRenderTargetWriteCycles);
COUNTER_SET(MTLCommonCounterSetTimestamp);
COUNTER_SET(MTLCommonCounterSetStageUtilization);
COUNTER_SET(MTLCommonCounterSetStatistic);
#undef COUNTER
#undef COUNTER_SET
#undef COUNTER_IMPORT
#endif
#define ENTRY(name) { #name, &name }
static const struct Identifier { const char* symbol; NSString* const* address; } identifiers[] = {
    ENTRY(MTLCommonCounterTimestamp), ENTRY(MTLCommonCounterTessellationInputPatches),
    ENTRY(MTLCommonCounterVertexInvocations), ENTRY(MTLCommonCounterPostTessellationVertexInvocations),
    ENTRY(MTLCommonCounterClipperInvocations), ENTRY(MTLCommonCounterClipperPrimitivesOut),
    ENTRY(MTLCommonCounterFragmentInvocations), ENTRY(MTLCommonCounterFragmentsPassed),
    ENTRY(MTLCommonCounterComputeKernelInvocations), ENTRY(MTLCommonCounterTotalCycles),
    ENTRY(MTLCommonCounterVertexCycles), ENTRY(MTLCommonCounterTessellationCycles),
    ENTRY(MTLCommonCounterPostTessellationVertexCycles), ENTRY(MTLCommonCounterFragmentCycles),
    ENTRY(MTLCommonCounterRenderTargetWriteCycles), ENTRY(MTLCommonCounterSetTimestamp),
    ENTRY(MTLCommonCounterSetStageUtilization), ENTRY(MTLCommonCounterSetStatistic),
};
#undef ENTRY
int main(void) {
    @autoreleasepool {
        setbuf(stdout,NULL); puts("ENTER Metal common counter identifiers");
        assert(NSClassFromString(@"MTLBlitPassDescriptor") != Nil);
        NSMutableSet* distinct=[NSMutableSet set];
        NSMutableDictionary* lookup=[NSMutableDictionary dictionary];
        NSMutableArray* originals=[NSMutableArray array];
        NSMutableArray* originalHashes=[NSMutableArray array];
        NSMutableArray* equalValues=[NSMutableArray array];
        NSString* originalPointers[sizeof(identifiers)/sizeof(identifiers[0])];
        for (NSUInteger i=0; i<sizeof(identifiers)/sizeof(identifiers[0]); ++i) {
            const struct Identifier entry=identifiers[i];
            if (entry.address == NULL) { printf("FAIL missing %s\n", entry.symbol); return 1; }
            NSString* value=*entry.address;
            assert([value isKindOfClass:[NSString class]] && value.length > 0);
            originalPointers[i]=value;
            [originals addObject:snapshotStringBytes(value)];
            [originalHashes addObject:@(value.hash)];
            NSString* copy=[value copy];
            assert([copy isEqualToString:value] && copy.hash == value.hash);
            NSString* independent=[[[NSString alloc] initWithUTF8String:value.UTF8String] autorelease];
            assert([independent isEqualToString:value] && independent.hash == value.hash);
            [equalValues addObject:independent];
            [lookup setObject:@(i) forKey:value];
            NSNumber* found=[lookup objectForKey:independent];
            assert(found != nil && found.unsignedIntegerValue == i);
            [distinct addObject:value];
            [copy release];
        }
        // Opaque project identifiers are distinct; this does not assert native raw strings.
        assert(distinct.count == sizeof(identifiers)/sizeof(identifiers[0]));
        for (NSUInteger operation=0;operation<3;++operation) {
            for (NSUInteger i=0;i<sizeof(identifiers)/sizeof(identifiers[0]);++i) {
                NSString* value=*identifiers[i].address;
                assertMutableCopyChanges(value,operation);
                assert(rejectsStringMutation(value,operation));
                for (NSUInteger j=0;j<sizeof(identifiers)/sizeof(identifiers[0]);++j) {
                    NSString* original=*identifiers[j].address;
                    assert(original==originalPointers[j]);
                    assert([snapshotStringBytes(original) isEqualToData:[originals objectAtIndex:j]]);
                    assert(original.hash==[[originalHashes objectAtIndex:j] unsignedIntegerValue]);
                    NSNumber* found=[lookup objectForKey:[equalValues objectAtIndex:j]];
                    assert(found != nil && found.unsignedIntegerValue==j);
                }
            }
        }
        puts("PASS: 18 immutable identifiers reject mutation; bytes/hash/keys and mutable copies verified");
    }
    return 0;
}
