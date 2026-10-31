# Genuine timestamp sampling milestone

This implementation adds the first real query path, limited to direct blit command
boundaries and shared-buffer CPU resolve. It does not close the full Metal, GPU,
application UI or stability roadmap.

`MTLDevice.counterSets` contains one actual `MTLCounterSet` named by the exported
`MTLCommonCounterSetTimestamp`, containing one actual `MTLCounter` named by
`MTLCommonCounterTimestamp`, only if Indium's actual selected graphics queue has
36–64 timestamp-valid bits and a finite positive timestamp period. The selection
uses the same graphics family and queue as `PrivateCommandBuffer::commit`, not an
arbitrary timestamp-capable transfer family. No graphics queue means unsupported.
`timestampComputeAndGraphics` is preserved but is not a substitute for per-family
valid bits. No extra Vulkan feature is needed for timestamp query pools.

Only `MTLCounterSamplingPointAtBlitBoundary` is advertised. Calls to
`sampleCountersInBuffer:atSampleIndex:withBarrier:` use a `VK_QUERY_TYPE_TIMESTAMP`
pool allocated for the buffer, command-buffer reset and BOTTOM_OF_PIPE timestamp
writes. `withBarrier:YES` adds full execution/memory barriers before sampling and
an execution barrier afterwards. Buffers are retained by the owning blit encoder,
which is retained through submission by its command buffer. Each index may be used
again only after its previous command finishes, or its unsubmitted command is
abandoned; an overlapping index is explicitly rejected. Cross-device objects,
out-of-range indices (including DontSample), ended encoders and committed command
buffers are rejected. DontSample is a pass-attachment sentinel, not an index alias
for zero in the direct command API.

Only this device's actual timestamp-set objects, shared mode and positive uint32
sample counts are accepted by creation. Functional Objective-C sampling remains
limited to the existing 64-bit Metal implementation; i386 reports empty sets/NO
and explicitly rejects allocation/sampling without referencing LP64-only classes. Invalid descriptors return nil plus an
Invalid NSError; Vulkan/host allocation exhaustion returns OutOfMemory, and other
creation failures return Internal. The native raw `MTLCounterErrorDomain` string
is GUESS/project opaque-token policy, as with the existing common identifiers;
its documented identifier, enum values and object identity are established, its
native raw bytes are not. This adds no claim of raw-value parity.

CPU resolve returns owned NSData of tightly packed `MTLCounterResultTimestamp`
values, in the Vulkan device's GPU tick domain. The public result layout is packed
(size8, alignment1), matching the published Metal C++ layout; the internal Vulkan
result/availability pair is explicitly aligned to eight bytes on both architectures. Queries that are unwritten,
unsubmitted, in flight or unavailable resolve to `MTLCounterErrorValue`; driver
errors return nil. Invalid ranges raise a range exception. A command's completion
state gates `vkGetQueryPoolResults`, so uninitialized queries are never read and
an old available value cannot bypass a newly queued reset. Reads request both
64-bit results and 64-bit availability and never request partial timestamp results.

The low `timestampValidBits` contain the actual sample, with no synthetic epoch.
A counter wraps modulo 2^validBits. The backend `elapsedTicks` helper masks the
unsigned difference, and `elapsedNanoseconds` multiplies that delta by the actual
`limits.timestampPeriod`. Such deltas require ordered samples within one submission and an interval
shorter than a full wrap. This implementation does not enable calibrated timestamps,
so it does not establish monotonicity or comparability across submissions. CPU time and GPU ticks are distinct clock domains; no CPU correlation,
frequency guess or CPU clock is substituted for a query. `sampleTimestamps:` stays
absent until genuine calibrated timestamps can satisfy its paired-clock contract.

StageBoundary remains NO because render vertex/fragment and compute pass boundaries
are not implemented. Blit descriptor attachments still explicitly reject buffers;
merely wiring blit attachments would not establish the advertised StageBoundary
contract, which covers the other pass kinds too. Four existing attachment slots
cover the one implemented set and are not a hardware capability count.
Private storage, GPU blit resolve, statistic counters and stage-utilization counters
remain unsupported. Nothing infers their existence from common identifier exports.

Provenance (no vendor binaries, local SDK extraction or tainted material):

- Rung 1: Apple's official Apache-2.0 metal-cpp MTLCounters.hpp and MTLDevice.hpp:
  public protocol members, error enums, timestamp layout, error/sentinel values
  and sampling-point enum values. LICENSE.txt read; no implementation copied.
  https://github.com/apple/metal-cpp/blob/main/Metal/MTLCounters.hpp
  https://github.com/apple/metal-cpp/blob/main/Metal/MTLDevice.hpp
  https://github.com/apple/metal-cpp/blob/main/LICENSE.txt
- Rung 3: Apple describes blit sampling between individual blit commands, shared
  CPU resolve, error values and GPU/CPU clock correlation:
  https://developer.apple.com/documentation/metal/mtlcountersamplingpoint/atblitboundary
  https://developer.apple.com/documentation/metal/mtlcountersamplingpoint/atstageboundary
  https://developer.apple.com/documentation/metal/mtlcountersamplebuffer/resolvecounterrange(_:)
  https://developer.apple.com/documentation/metal/gpu-counters-and-counter-sample-buffers
  https://developer.apple.com/documentation/metal/converting-gpu-timestamps-into-cpu-time
- Primary backend specification: query ownership/reset/write, valid bits, period,
  availability and stale-value hazard:
  https://docs.vulkan.org/refpages/latest/refpages/source/VkQueueFamilyProperties.html
  https://docs.vulkan.org/refpages/latest/refpages/source/VkPhysicalDeviceLimits.html
  https://docs.vulkan.org/refpages/latest/refpages/source/vkCreateQueryPool.html
  https://docs.vulkan.org/refpages/latest/refpages/source/vkCmdResetQueryPool.html
  https://docs.vulkan.org/refpages/latest/refpages/source/vkCmdWriteTimestamp.html
  https://docs.vulkan.org/refpages/latest/refpages/source/vkGetQueryPoolResults.html
- Conservative project restrictions: rejecting overlapping writes to one sample
  index and limiting storage/sampling/resolve paths to those implemented here.
  Native parity for these invalid/unsupported cases is not claimed.

Verification:

`tests/metal-timestamps.m` was frozen unchanged outside this checkout before
production edits (SHA256 5cf449df462c460ce27796c0d72ac2bbaafbd34f7f2408ce456ef7188fe6a913).
Typed fallback protocols let the same caller compile against baseline headers.
On a real enabled device, BEFORE reports missing counter capability API with
exit42. Candidate must inspect the actual set/counter objects, see only blit support,
write index0 and index1 around real buffer fill work, reject pre-submit results,
wait for completion, verify actual resolved samples and fill bytes, and leave
unwritten index2 unavailable. Unsupported queue path exits77 with zero sets.
The coordinator alone owns installed BEFORE/candidate execution and real GPU proof.

Native `deps/indium/test/timestamps/queries.cpp` compiles the actual production
counter.cpp with injected owned Vulkan dispatch and narrow completion/device stubs.
It checks the actual queue-metadata helper (including a selected zero-bit family
while another family supports timestamps), capability predicates and invalid periods,
allocation failure and destruction, cross-device/index/range rejection, exact query
reset/write calls, result flags/layout, unwritten/in-flight availability, stale reset
suppression, completed and abandoned owners, index reuse, valid-bit masking,
wraparound and period conversion. This is source-level query logic evidence, not
hardware, submission or Objective-C bridge runtime evidence.

`tests/metal-timestamps-validation.m` is a separate candidate-only public fixture
for invalid descriptors, unsupported modes/counts/foreign sets, label snapshots,
invalid ranges, DontSample rejection, in-flight reuse and ended encoders. It is
compiled here; coordinator execution is still required.

`tests/metal-timestamp-layout.m` is a compile-only public layout control for size,
alignment and timestamp offset, including the packed result in an enclosing struct.
It builds for both configured target architectures and needs no device.
