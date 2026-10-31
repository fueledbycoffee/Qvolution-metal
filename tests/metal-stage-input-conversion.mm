// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#import <Metal/MTLStageInputOutputDescriptorInternal.h>
#import <Metal/MTLComputePipelineInternal.h>
#include <cassert>
#include <cstdio>
#ifndef DARLING_METAL_ENABLED
#error This fixture needs the Indium conversion API, not a GPU device
#endif
#ifdef NDEBUG
#error Assertions required
#endif
int main() {
	@autoreleasepool {
		setbuf(stdout, nullptr);
		MTLStageInputOutputDescriptor* stage = [MTLStageInputOutputDescriptor stageInputOutputDescriptor];
		auto empty = [stage asIndiumDescriptor];
		assert(empty.attributes.empty() && empty.layouts.empty());
		stage.attributes[2].format = MTLAttributeFormatFloat3;
		stage.attributes[2].offset = 12;
		stage.attributes[2].bufferIndex = 3;
		stage.layouts[3].stride = 32;
		stage.layouts[3].stepFunction = MTLStepFunctionThreadPositionInGridXIndexed;
		stage.layouts[3].stepRate = 4;
		stage.indexType = MTLIndexTypeUInt32;
		stage.indexBufferIndex = 5;
		auto metadata = [stage asIndiumDescriptor];
		assert(metadata.attributes.size() == 1 && metadata.layouts.size() == 1);
		assert(metadata.attributes.at(2).format == Indium::AttributeFormat::Float3);
		assert(metadata.attributes.at(2).offset == 12 && metadata.attributes.at(2).bufferIndex == 3);
		assert(metadata.layouts.at(3).stride == 32 && metadata.layouts.at(3).stepRate == 4);
		assert(metadata.layouts.at(3).stepFunction == Indium::StepFunction::ThreadPositionInGridXIndexed);
		assert(metadata.indexType == Indium::IndexType::UInt32 && metadata.indexBufferIndex == 5);
		MTLComputePipelineDescriptor* compute = [[MTLComputePipelineDescriptor alloc] init];
		auto noStage = [compute asIndiumDescriptor];
		assert(noStage.computeFunction == nullptr && !noStage.stageInputDescriptor);
		compute.stageInputDescriptor = stage;
		stage.attributes[2].offset = 99;
		auto pipeline = [compute asIndiumDescriptor];
		assert(pipeline.computeFunction == nullptr && pipeline.stageInputDescriptor.has_value());
		assert(pipeline.stageInputDescriptor->attributes.at(2).offset == 12);
		assert(pipeline.stageInputDescriptor->layouts.at(3).stride == 32);
		assert(pipeline.stageInputDescriptor->indexBufferIndex == 5);
		[stage reset];
		assert([stage asIndiumDescriptor].attributes.empty());
		assert(metadata.attributes.at(2).offset == 12);
		[compute reset];
		auto reset = [compute asIndiumDescriptor];
		assert(reset.computeFunction == nullptr && !reset.stageInputDescriptor);
		[compute release];
		puts("PASS: actual stage-input metadata reaches Indium optional without a GPU");
	}
}
