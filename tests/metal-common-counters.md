# Common counter and counter-set identifier strings

MTLCounters.h exposes the complete documented common identifier family:
MTLCommonCounter and MTLCommonCounterSet are NSString* const aliases; there are
15 common counter identifiers and three common counter-set identifiers. They
are immutable names for equality, hashing and collection keys, not samples or
claims that a device supports the corresponding counter. Counters and sets use
separate opaque identifiers, including the two timestamp names.

The timestamp set names the timestamp counter. The statistic set names compute
kernel invocations, vertex invocations, fragment invocations, fragments passed,
tessellation input patches, post-tessellation vertex invocations, clipper
invocations and clipper primitives out. The stage-utilization set names total,
vertex, tessellation, post-tessellation vertex, fragment and render-target-write
cycles. This grouping describes the public API; no device/set objects or backend
members are manufactured from it.

Provenance:

- Rung 1: Apple's official Apache-2.0 metal-cpp Metal/MTLCounters.hpp establishes
  all names and NSString object identities; LICENSE.txt was read. The published
  implementation resolves exported object globals and does not reveal their
  raw string values. No implementation or SDK code is copied.
  https://developer.apple.com/metal/cpp/
  https://github.com/apple/metal-cpp/blob/main/Metal/MTLCounters.hpp
  https://github.com/apple/metal-cpp/blob/main/LICENSE.txt
- Rung 3: public Objective-C typedef/global declarations and semantic names:
  https://developer.apple.com/documentation/metal/mtlcommoncounter?language=objc
  https://developer.apple.com/documentation/metal/mtlcommoncounterset?language=objc
  https://developer.apple.com/documentation/metal/mtlcommoncounterset/timestamp?language=objc
  https://developer.apple.com/documentation/metal/mtlcommoncounterset/statistic?language=objc
  https://developer.apple.com/documentation/metal/mtlcommoncounterset/stageutilization?language=objc
- GUESS/project policy (rung 6): the immutable string contents use the documented
  public symbol spelling as a distinct opaque identity token. Native raw text is
  unestablished. No test asserts native spelling equivalence, and callers that
  rely on native raw-value literals are not verified. A future backend should
  expose these exported identifiers for matching supported names rather than
  derive availability from their existence. Raw-value parity remains an explicit
  open issue for permitted primary evidence or public API boundary observation.

Tests and evidence:

- metal-common-counters.m has typed fallback declarations so the unchanged
  source supplies a normal strong-link BEFORE control. That link against the
  installed Stage34 Metal fails on all 18 names. A COUNTER_WEAK_CONTROL build
  uses weak imports; the local linker additionally needs -undefined dynamic_lookup
  to produce a runnable missing-export control. That special control is not the
  normal-link success criterion. Before objects, source, argv and logs are frozen
  outside the checkout; the coordinator owns guest execution.
- The normal typed candidate fixture checks nonnil immutable NSString objects,
  equality/hash, copy behavior, key lookup and the distinct opaque-token policy.
  It first confirms the existing MTLBlitPassDescriptor class. It never requests a
  device, enumerates counters, samples or resolves a timestamp. A fixture linked
  with the authored identifier-only object checks model behavior; integrated
  export acceptance requires normal linking to the subsequently staged framework.
- metal-common-counters-const.m is a negative compile control: both assignments
  must fail for const-qualified MTLCommonCounter/MTLCommonCounterSet types.
  Compile all fixtures with assertions enabled (-UNDEBUG). The identifier source
  builds both with and without DARLING_METAL_ENABLED and requires no GPU.

Actual query availability audit (vendored source, rung 2):

MTLDevice.h deliberately omits supportsCounterSampling: and counterSets is absent.
MTLCounterSampleBuffer.h omits newCounterSampleBufferWithDescriptor:error: until
there is a genuine backend. Indium counter.hpp provides only an abstract sample
buffer interface; counter.cpp supplies its destructor. No query pool, timestamp
write, query-result retrieval, performance-counter enumeration or concrete sample
buffer exists. device.cpp already queries/stores VkPhysicalDeviceProperties and
queries queue-family properties to choose queues, but does not consume timestamp
limits or preserve/expose per-queue timestamp-valid bits for sampling. Timeline
semaphore counters used elsewhere are synchronization state, not GPU timestamps.
These are implementation facts, not a claim that the physical GPU lacks queries.

Subsequent genuine counter implementation plan (owner: Metal/Indium maintainers):

1. Extend Indium device.cpp/device.private.hpp at existing physical-device and
   queue-family discovery. Preserve timestampValidBits for the actual selected
   command queue, limits.timestampPeriod and timestampComputeAndGraphics, then
   validate usable timestamp support. Zero valid bits means that queue cannot
   timestamp. Public device.counterSets must expose only implemented, supported
   sets; supportsCounterSampling: must describe only boundaries correctly encoded
   on that queue. No timestamp set is inferred from the existence of a constant.
2. Add owned query-pool allocation and a concrete CounterSampleBuffer in Indium's
   counter source/private interface. Implement real Metal counter/counter-set/
   sample-buffer objects, identity mapping, device validation, sample counts,
   storage modes and allocation errors. Resize pass attachment arrays to at least
   the actual supported counter-set count; the current four-slot no-counter limit
   must not become a device-capability claim.
3. Register needed query functions in dynamic-vk.hpp. Reset real queries and write
   timestamp queries at correctly synchronized supported pass/command boundaries;
   respect queue/stage restrictions and DontSample versus valid sample index zero.
   Add owning snapshot conversion in each pass bridge; remove explicit sampling
   rejection only for the supported real path. Preserve resources through queued
   submission and report allocation, encoding and submission failures explicitly.
4. Retrieve actual 64-bit query results and availability, mask/wrap valid bits and
   use the real timestamp period where conversion is required. Implement CPU and
   blit resolve APIs to documented result types. CPU/GPU clock correlation must
   use genuine calibration support or remain explicitly unsupported. Never reuse
   semaphore values, CPU clock readings or synthetic increments as GPU samples.
5. Map statistic or stage-utilization counters only when Vulkan's implemented
   query features or enumerated performance counters have the documented meaning
   and units. Similar names alone are not a mapping; unsupported counters/sets
   remain absent. Validate any required profiling locks or multi-pass collection.
6. Prove capability selection with zero/nonzero valid-bit queue cases, query
   ownership and allocation failures, sample bounds, DontSample/index0 separation,
   result readiness, wraparound, period conversion and actual-device samples.
   Coordinator acceptance must exercise real work, resolved data and unsupported
   paths; identifier/model tests alone cannot close this work.

Primary backend contracts for that subsequent plan:
https://docs.vulkan.org/refpages/latest/refpages/source/VkQueueFamilyProperties.html
https://docs.vulkan.org/refpages/latest/refpages/source/VkPhysicalDeviceLimits.html
https://docs.vulkan.org/refpages/latest/refpages/source/vkCmdWriteTimestamp.html
https://docs.vulkan.org/refpages/latest/refpages/source/vkGetQueryPoolResults.html
https://docs.vulkan.org/refpages/latest/refpages/source/VK_KHR_performance_query.html
