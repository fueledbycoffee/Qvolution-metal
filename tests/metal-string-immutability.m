// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#import "metal-string-immutability.h"
#include <stdio.h>
#ifdef NDEBUG
#error Assertions required
#endif
int main(void) {
    @autoreleasepool {
        setbuf(stdout,NULL); puts("ENTER isolated constant string mutation control");
        // This literal belongs only to this authored executable, not a framework export.
        NSString* literal=@"Qvolution_own_literal_immutability_probe_20261031_c2d89";
        NSData* original=snapshotStringBytes(literal);
        NSUInteger hash=literal.hash;
        NSString* equal=[[[NSString alloc] initWithData:original encoding:NSUTF8StringEncoding] autorelease];
        NSDictionary* lookup=@{literal:@"value"};
        printf("DIAGNOSTIC class=%s mutableClassMembership=%d\n", NSStringFromClass([literal class]).UTF8String,
               [literal isKindOfClass:[NSMutableString class]]);
        for (NSUInteger operation=0;operation<3;++operation) {
            assertMutableCopyChanges(literal,operation);
            assert(rejectsStringMutation(literal,operation));
            assert([snapshotStringBytes(literal) isEqualToData:original] && literal.hash==hash);
            assert([[lookup objectForKey:equal] isEqualToString:@"value"]);
            printf("REJECT isolated mutation %lu; literal bytes/hash/key intact\n",(unsigned long)operation);
        }
        puts("PASS: isolated literal rejects mutation while mutable copies change independently");
    }
}
