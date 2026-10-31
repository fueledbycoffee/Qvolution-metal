// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#ifndef _METAL_MTLSTAGEINPUTOUTPUTDESCRIPTOR_H_
#define _METAL_MTLSTAGEINPUTOUTPUTDESCRIPTOR_H_
#import <Foundation/Foundation.h>
#import <Metal/MTLRenderCommandEncoder.h>
#import <Metal/MTLDefines.h>

METAL_DECLARATIONS_BEGIN

// MTLAttributeFormat is transcribed from Apple's MTLStageInputOutputDescriptor.h
// rather than written out, so no enumerator here is a hand-typed value.
typedef NS_ENUM(NSUInteger, MTLAttributeFormat) {
	MTLAttributeFormatInvalid = 0,
	MTLAttributeFormatUChar2 = 1,
	MTLAttributeFormatUChar3 = 2,
	MTLAttributeFormatUChar4 = 3,
	MTLAttributeFormatChar2 = 4,
	MTLAttributeFormatChar3 = 5,
	MTLAttributeFormatChar4 = 6,
	MTLAttributeFormatUChar2Normalized = 7,
	MTLAttributeFormatUChar3Normalized = 8,
	MTLAttributeFormatUChar4Normalized = 9,
	MTLAttributeFormatChar2Normalized = 10,
	MTLAttributeFormatChar3Normalized = 11,
	MTLAttributeFormatChar4Normalized = 12,
	MTLAttributeFormatUShort2 = 13,
	MTLAttributeFormatUShort3 = 14,
	MTLAttributeFormatUShort4 = 15,
	MTLAttributeFormatShort2 = 16,
	MTLAttributeFormatShort3 = 17,
	MTLAttributeFormatShort4 = 18,
	MTLAttributeFormatUShort2Normalized = 19,
	MTLAttributeFormatUShort3Normalized = 20,
	MTLAttributeFormatUShort4Normalized = 21,
	MTLAttributeFormatShort2Normalized = 22,
	MTLAttributeFormatShort3Normalized = 23,
	MTLAttributeFormatShort4Normalized = 24,
	MTLAttributeFormatHalf2 = 25,
	MTLAttributeFormatHalf3 = 26,
	MTLAttributeFormatHalf4 = 27,
	MTLAttributeFormatFloat = 28,
	MTLAttributeFormatFloat2 = 29,
	MTLAttributeFormatFloat3 = 30,
	MTLAttributeFormatFloat4 = 31,
	MTLAttributeFormatInt = 32,
	MTLAttributeFormatInt2 = 33,
	MTLAttributeFormatInt3 = 34,
	MTLAttributeFormatInt4 = 35,
	MTLAttributeFormatUInt = 36,
	MTLAttributeFormatUInt2 = 37,
	MTLAttributeFormatUInt3 = 38,
	MTLAttributeFormatUInt4 = 39,
	MTLAttributeFormatInt1010102Normalized = 40,
	MTLAttributeFormatUInt1010102Normalized = 41,
	MTLAttributeFormatUChar4Normalized_BGRA = 42,
	MTLAttributeFormatUChar = 45,
	MTLAttributeFormatChar = 46,
	MTLAttributeFormatUCharNormalized = 47,
	MTLAttributeFormatCharNormalized = 48,
	MTLAttributeFormatUShort = 49,
	MTLAttributeFormatShort = 50,
	MTLAttributeFormatUShortNormalized = 51,
	MTLAttributeFormatShortNormalized = 52,
	MTLAttributeFormatHalf = 53,
};


typedef NS_ENUM(NSUInteger, MTLStepFunction) {
	MTLStepFunctionConstant = 0,
	MTLStepFunctionPerVertex = 1,
	MTLStepFunctionPerInstance = 2,
	MTLStepFunctionPerPatch = 3,
	MTLStepFunctionPerPatchControlPoint = 4,
	MTLStepFunctionThreadPositionInGridX = 5,
	MTLStepFunctionThreadPositionInGridY = 6,
	MTLStepFunctionThreadPositionInGridXIndexed = 7,
	MTLStepFunctionThreadPositionInGridYIndexed = 8,
};

MTL_EXPORT
@interface MTLAttributeDescriptor : NSObject <NSCopying> {
	MTLAttributeFormat _format;
	NSUInteger _offset, _bufferIndex;
}
@property(nonatomic) MTLAttributeFormat format;
@property(nonatomic) NSUInteger offset;
@property(nonatomic) NSUInteger bufferIndex;
@end

MTL_EXPORT
@interface MTLBufferLayoutDescriptor : NSObject <NSCopying> {
	NSUInteger _stride, _stepRate;
	MTLStepFunction _stepFunction;
}
@property(nonatomic) NSUInteger stride;
@property(nonatomic) MTLStepFunction stepFunction;
@property(nonatomic) NSUInteger stepRate;
@end

MTL_EXPORT
@interface MTLAttributeDescriptorArray : NSObject {
	NSMutableDictionary<NSNumber*, MTLAttributeDescriptor*>* _descriptors;
}
- (MTLAttributeDescriptor*)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(MTLAttributeDescriptor*)descriptor atIndexedSubscript:(NSUInteger)index;
@end

MTL_EXPORT
@interface MTLBufferLayoutDescriptorArray : NSObject {
	NSMutableDictionary<NSNumber*, MTLBufferLayoutDescriptor*>* _descriptors;
}
- (MTLBufferLayoutDescriptor*)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(MTLBufferLayoutDescriptor*)descriptor atIndexedSubscript:(NSUInteger)index;
@end

MTL_EXPORT
@interface MTLStageInputOutputDescriptor : NSObject <NSCopying> {
	MTLAttributeDescriptorArray* _attributes;
	MTLBufferLayoutDescriptorArray* _layouts;
	NSUInteger _indexBufferIndex;
	MTLIndexType _indexType;
}
@property(readonly) MTLAttributeDescriptorArray* attributes;
@property(readonly) MTLBufferLayoutDescriptorArray* layouts;
@property(nonatomic) NSUInteger indexBufferIndex;
@property(nonatomic) MTLIndexType indexType;
+ (MTLStageInputOutputDescriptor*)stageInputOutputDescriptor;
- (void)reset;
@end

METAL_DECLARATIONS_END
#endif
