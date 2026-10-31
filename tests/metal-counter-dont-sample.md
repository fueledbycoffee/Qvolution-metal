# Counter sampling sentinel

The previous public macro equated MTLCounterDontSample with sample index zero.
The authored metal-counter-dont-sample.m regression asserts that the sentinel is
NSUIntegerMax and zero remains a usable sample index, then exercises the existing
compute attachment's initialization, setter round trips and independent copy.
It needs assertions enabled (-UNDEBUG), Foundation and the real Metal library.
It does not create a device or claim counter execution.

Provenance: clean-room rung 1, Apple's official Apache-2.0 metal-cpp source,
Metal/MTLCounters.hpp (CounterDontSample is an unsigned integer converted from
-1). https://developer.apple.com/metal/cpp/ directly links the source repository:
https://github.com/apple/metal-cpp/blob/main/Metal/MTLCounters.hpp
https://github.com/apple/metal-cpp/blob/main/LICENSE.txt
No implementation code or SDK headers were copied. Rung 3 documentation defines
its purpose and requires it on devices lacking stage-boundary sampling:
https://developer.apple.com/documentation/metal/mtlcounterdontsample
https://developer.apple.com/documentation/metal/mtlcomputepasssamplebufferattachmentdescriptor/startofencodersampleindex

Initializing both sample indices to that sentinel is conservative project policy
(rung 6), not an observed native default. The fetched public contracts do not
specify numeric index defaults. This avoids accidental sample-zero requests on
an implementation with no counter sampling. The sample buffer still defaults to
nil. Existing compute-array/compute-pass copy behavior is outside this change.
