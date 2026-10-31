// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#import <Metal/MTLStageInputOutputDescriptorInternal.h>

static const NSUInteger MTLStageDescriptorSlotCount = 31;

static void checkIndex(NSUInteger index) {
	if (index >= MTLStageDescriptorSlotCount)
		[NSException raise:NSRangeException format:@"Metal stage descriptor index %lu exceeds %lu slots", (unsigned long)index, (unsigned long)MTLStageDescriptorSlotCount];
}

static id descriptorAtIndex(NSMutableDictionary* entries, NSUInteger index, Class type) {
	checkIndex(index);
	id descriptor = entries[@(index)];
	if (descriptor == nil) {
		descriptor = [[type alloc] init];
		entries[@(index)] = descriptor;
		[descriptor release];
	}
	return [[descriptor retain] autorelease];
}

static void setDescriptor(NSMutableDictionary* entries, NSUInteger index, id descriptor, Class type) {
	checkIndex(index);
	if (descriptor != nil && ![descriptor isKindOfClass:type])
		[NSException raise:NSInvalidArgumentException format:@"Expected %@ for Metal stage descriptor", NSStringFromClass(type)];
	if (descriptor == nil)
		[entries removeObjectForKey:@(index)];
	else
		entries[@(index)] = descriptor;
}

static void copyDescriptors(NSMutableDictionary* target, NSDictionary* source) {
	for (NSNumber* index in source) {
		id descriptor = [source[index] copy];
		target[index] = descriptor;
		[descriptor release];
	}
}

@interface MTLAttributeDescriptorArray (Storage) <NSCopying>
- (void)reset;
@end
@interface MTLBufferLayoutDescriptorArray (Storage) <NSCopying>
- (void)reset;
@end

@implementation MTLAttributeDescriptor
@synthesize format = _format, offset = _offset, bufferIndex = _bufferIndex;
- (instancetype)init {
	if ((self = [super init])) _format = MTLAttributeFormatInvalid;
	return self;
}
- (id)copyWithZone:(NSZone*)zone {
	MTLAttributeDescriptor* result = [[[self class] allocWithZone:zone] init];
	result.format = _format; result.offset = _offset; result.bufferIndex = _bufferIndex;
	return result;
}
@end

@implementation MTLBufferLayoutDescriptor
@synthesize stride = _stride, stepFunction = _stepFunction, stepRate = _stepRate;
- (instancetype)init {
	if ((self = [super init])) {
		_stepFunction = MTLStepFunctionPerInstance;
		_stepRate = 1;
	}
	return self;
}
- (id)copyWithZone:(NSZone*)zone {
	MTLBufferLayoutDescriptor* result = [[[self class] allocWithZone:zone] init];
	result.stride = _stride; result.stepFunction = _stepFunction; result.stepRate = _stepRate;
	return result;
}
@end

@implementation MTLAttributeDescriptorArray
- (instancetype)init {
	if ((self = [super init])) _descriptors = [NSMutableDictionary new];
	return self;
}
- (void)dealloc { [_descriptors release]; [super dealloc]; }
- (MTLAttributeDescriptor*)objectAtIndexedSubscript:(NSUInteger)index {
	return descriptorAtIndex(_descriptors, index, [MTLAttributeDescriptor class]);
}
- (void)setObject:(MTLAttributeDescriptor*)descriptor atIndexedSubscript:(NSUInteger)index {
	setDescriptor(_descriptors, index, descriptor, [MTLAttributeDescriptor class]);
}
- (void)reset { [_descriptors removeAllObjects]; }
- (id)copyWithZone:(NSZone*)zone {
	MTLAttributeDescriptorArray* result = [[[self class] allocWithZone:zone] init];
	copyDescriptors(result->_descriptors, _descriptors);
	return result;
}
@end

@implementation MTLBufferLayoutDescriptorArray
- (instancetype)init {
	if ((self = [super init])) _descriptors = [NSMutableDictionary new];
	return self;
}
- (void)dealloc { [_descriptors release]; [super dealloc]; }
- (MTLBufferLayoutDescriptor*)objectAtIndexedSubscript:(NSUInteger)index {
	return descriptorAtIndex(_descriptors, index, [MTLBufferLayoutDescriptor class]);
}
- (void)setObject:(MTLBufferLayoutDescriptor*)descriptor atIndexedSubscript:(NSUInteger)index {
	setDescriptor(_descriptors, index, descriptor, [MTLBufferLayoutDescriptor class]);
}
- (void)reset { [_descriptors removeAllObjects]; }
- (id)copyWithZone:(NSZone*)zone {
	MTLBufferLayoutDescriptorArray* result = [[[self class] allocWithZone:zone] init];
	copyDescriptors(result->_descriptors, _descriptors);
	return result;
}
@end

@implementation MTLStageInputOutputDescriptor
@synthesize attributes = _attributes, layouts = _layouts;
@synthesize indexType = _indexType, indexBufferIndex = _indexBufferIndex;
+ (MTLStageInputOutputDescriptor*)stageInputOutputDescriptor { return [[[self alloc] init] autorelease]; }
- (instancetype)init {
	if ((self = [super init])) {
		_attributes = [MTLAttributeDescriptorArray new];
		_layouts = [MTLBufferLayoutDescriptorArray new];
		_indexType = MTLIndexTypeUInt16;
	}
	return self;
}
- (void)dealloc { [_attributes release]; [_layouts release]; [super dealloc]; }
- (void)reset {
	[_attributes reset]; [_layouts reset];
	_indexBufferIndex = 0; _indexType = MTLIndexTypeUInt16;
}
- (id)copyWithZone:(NSZone*)zone {
	MTLStageInputOutputDescriptor* result = [[[self class] allocWithZone:zone] init];
	[result->_attributes release]; result->_attributes = [_attributes copy];
	[result->_layouts release]; result->_layouts = [_layouts copy];
	result.indexType = _indexType; result.indexBufferIndex = _indexBufferIndex;
	return result;
}
@end

#if DARLING_METAL_ENABLED
static_assert(MTLAttributeFormatFloat3 == static_cast<NSUInteger>(Indium::AttributeFormat::Float3));
static_assert(MTLStepFunctionThreadPositionInGridYIndexed == static_cast<NSUInteger>(Indium::StepFunction::ThreadPositionInGridYIndexed));

@implementation MTLAttributeDescriptorArray (Internal)
- (std::unordered_map<size_t, Indium::AttributeDescriptor>)asIndiumDescriptors {
	std::unordered_map<size_t, Indium::AttributeDescriptor> result;
	for (NSNumber* index in _descriptors) {
		MTLAttributeDescriptor* descriptor = _descriptors[index];
		result[index.unsignedIntegerValue] = {descriptor.bufferIndex, descriptor.offset, static_cast<Indium::AttributeFormat>(descriptor.format)};
	}
	return result;
}
@end

@implementation MTLBufferLayoutDescriptorArray (Internal)
- (std::unordered_map<size_t, Indium::BufferLayoutDescriptor>)asIndiumDescriptors {
	std::unordered_map<size_t, Indium::BufferLayoutDescriptor> result;
	for (NSNumber* index in _descriptors) {
		MTLBufferLayoutDescriptor* descriptor = _descriptors[index];
		result[index.unsignedIntegerValue] = {descriptor.stride, static_cast<Indium::StepFunction>(descriptor.stepFunction), descriptor.stepRate};
	}
	return result;
}
@end

@implementation MTLStageInputOutputDescriptor (Internal)
- (Indium::StageInputOutputDescriptor)asIndiumDescriptor {
	return Indium::StageInputOutputDescriptor {
		[_attributes asIndiumDescriptors],
		[_layouts asIndiumDescriptors],
		_indexBufferIndex,
		static_cast<Indium::IndexType>(_indexType),
	};
}
@end
#endif
