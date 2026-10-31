# Blit-pass configuration and execution

metal-blit-pass.m is a typed public API fixture that links against the real Metal
library. Its protocol declarations permit the same source to compile before the
new classes exist. It first confirms the existing MTLCommandBufferDescriptor,
then checks all three new classes, retained sample-buffer ownership, typed slot
assignment isolation, independent copies, nil clearing and bounds. Use -UNDEBUG.
No device is requested. This is descriptor evidence, not proof of GPU work.

metal-blit-pass-conversion.mm also includes Metal's private headers and existing
Indium include dependencies with DARLING_METAL_ENABLED=1. It verifies empty
sampling configuration becomes the existing Indium descriptor; configuring a
sample buffer raises NSInternalInconsistencyException with an explicit reason.
Clearing that slot restores conversion. No device is requested.

metal-blit-pass-buffer.m is the separate execution gate. With an actual available
Metal device, it creates real shared buffers and compares every byte after copy
and fill commands encoded through blitCommandEncoderWithDescriptor:. It also
checks sampling rejection occurs before an encoder is created and the same
command buffer remains usable after clearing the attachment. Exit 77 means no
real device was available and execution remains unverified. Do not enable a
fake device or infer successful blits from class availability.

All fixtures link Foundation, Metal, objc and system, and the C++ conversion
fixture also needs libc++. Build with the existing Darling target flags and link
against a committed private runtime. The coordinator owns heavy builds, installs,
guest runs and prefix shutdown. A data-only object can be linked directly into
the metadata fixture for ownership checks without changing a runtime; that does
not test the command-buffer integration. Keep the pre-change fixture executable
when rebuilding a candidate.

Contracts and policies:

- Rung 2: vendored Metal compute/stage descriptor ownership patterns and Indium
  blit-command-encoder.hpp, command-buffer.cpp and blit-command-encoder.cpp.
  The existing descriptor overload creates a real blit encoder; its stored
  sample attachment configuration is never consumed by GPU query commands.
- Rung 3 public APIs: https://developer.apple.com/documentation/metal/mtlblitpassdescriptor
  https://developer.apple.com/documentation/metal/mtlblitpasssamplebufferattachmentdescriptor
  https://developer.apple.com/documentation/metal/mtlblitpasssamplebufferattachmentdescriptorarray
  https://developer.apple.com/documentation/metal/mtlblitpasssamplebufferattachmentdescriptor/samplebuffer
  https://developer.apple.com/documentation/metal/mtlcommandbuffer/makeblitcommandencoder(descriptor:)
  The sample buffer's nil default disables sampling. CounterDontSample's numeric
  contract and the conservative default-index policy are in metal-counter-dont-sample.md.
- Rung 3 array setter contract: copy the supplied descriptor's properties into
  an array-owned instance. This implementation preserves destination identity,
  isolates subsequent source and duplicate-slot mutations, and retains the shared
  sample buffer resource. The array page also specifies capacity of at least the
  device's counterSets count:
  https://developer.apple.com/documentation/metal/mtlblitpasssamplebufferattachmentdescriptorarray?changes=lat__6&language=objc
- GUESS/project policy (rung 6): four lazy slots (indices 0..3) are a limit of this
  implementation's currently unsupported/no-counter backend, not a native size.
  A future counter-capable backend must size its array for the actual counter-set
  count. Deep copies, stable destination identity, nil resetting its properties,
  NSRangeException for invalid indices and NSInvalidArgumentException for wrong
  types are explicit policies where the primary contract does not specify them.
  Any assigned sample buffer is rejected at the backend boundary, including one
  with both indices set to DontSample. Nothing is silently dropped from an active
  sampling request. Numeric index values round-trip unchanged.

Counter sampling implementation roadmap (owner: Metal/Indium maintainers):

1. Query actual Vulkan queue timestamp-valid bits, timestamp period and available
   performance counters. Expose only supported counter sets and sampling points;
   preserve unsupported errors where a backend lacks the requested capability.
2. Implement owned Indium query pools and MTLCounterSampleBuffer allocation with
   device identity, storage mode, sample-count/bounds validation and allocation
   errors; map the real buffer to the public protocol and descriptor bridge.
   Replace the current no-counter four-slot limit with capacity derived from the
   real supported counter sets, meeting the public array's minimum capacity.
3. Encode query reset, start/end samples and synchronization for each supported
   boundary. Handle DontSample separately from valid index zero; retain resources
   until submission completes and propagate command-buffer errors.
4. Resolve real query results into documented counter result types, respecting
   availability, wraparound, timestamp period, invalid values and CPU/GPU storage
   synchronization. Implement the CPU and blit resolve APIs without invented data.
5. Test timestamps, ordering, bounds, ownership, unsupported-device paths and
   error propagation on actual capable/incapable devices. Only then remove the
   explicit sample-buffer rejection. No GPU capability or timestamp is fabricated
   by this descriptor implementation, and the default device policy is unchanged.
