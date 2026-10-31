# Stage input/output descriptor metadata

Build/run metal-stage-input.m against Metal and Foundation with assertions
enabled (-UNDEBUG), in the normal default/no-GPU-device configuration. It links
the actual existing Metal library and checks its ComputePipelineDescriptor class
before checking the five new data classes. The parent fails at missing Stage.
No GPU creation, queue, shader compile or dispatch is needed for this fixture.

metal-stage-input-conversion.mm additionally needs Metal's private include path,
the configured Indium include dependencies and DARLING_METAL_ENABLED=1. It checks
actual descriptor-to-Indium data, sparse maps, nil computeFunction safety and
optional stage configuration. Setting stageInputDescriptor now reaches Indium;
it is no longer silently replaced by std::nullopt. Indium's compute-stage-in path
still explicitly reports unsupported. These tests do not claim such a shader can
execute, GPU device availability, image output or full Qt/KeePassXC support.

The public descriptor data source also compiles without DARLING_METAL_ENABLED;
that compile check does not claim the existing disabled-backend ComputePipeline
class is functional. The default runtime device policy is not changed.

Provenance and policy:

- Public class/property/reset/copy and typed-array interfaces: Apple's public docs
  https://developer.apple.com/documentation/metal/mtlstageinputoutputdescriptor
  https://developer.apple.com/documentation/metal/mtlattributedescriptor
  https://developer.apple.com/documentation/metal/mtlbufferlayoutdescriptor
  https://developer.apple.com/documentation/metal/mtlattributedescriptorarray
  https://developer.apple.com/documentation/metal/mtlbufferlayoutdescriptorarray
- MTLAttributeFormat is moved unchanged from this tree's vendored geometry header,
  not redeclared. IndexType reuses the vendored render encoder declaration.
  StepFunction numeric mappings and descriptor metadata match existing Indium
  types.hpp/compute-pipeline.hpp; no new backend values are invented.
- Apple's fetched public documentation does not specify these defaults. GUESS:
  use existing Indium policy (formatInvalid/offset0/buffer0; layoutstride0,
  stepPerInstance/rate1; indexUInt16/index0). These are not observed Mac defaults.
- GUESS: typed arrays expose31slots(0..30), matching this tree's existing vertex
  descriptor policy. Out-of-range access raises NSRangeException; wrong type
  assignment raises NSInvalidArgumentException. No observed Mac exception/limit
  equivalence is claimed. Nil assignment clears a slot; next access creates a
  default child. Setters retain assigned children; stage/array copies deep-copy
  children. Reset clears children and restores numeric defaults.

Rung2 existing descriptor/API/backend source and rung3 public interfaces; uncertain
default/bounds/ownership choices explicitly labeled policy (rung6). Public and
conversion source fixtures supply boundary observations (rung4) after staging.
No Apple binaries/SDKs were inspected and no new symbol-only empty class was added.
All new source retains the Metal component's MPL-2.0 SPDX license.

Candidate isolated sources and fixtures compile with existing Metal flags; normal
runtime execution remains a coordinator gate. The parent class failure was
observed independently (exit134/exactshutdown0). Track loader class availability,
metadata behavior and actual GPU support as separate milestones.
