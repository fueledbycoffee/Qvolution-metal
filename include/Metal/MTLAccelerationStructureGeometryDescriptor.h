// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#ifndef _METAL_MTLACCELERATIONSTRUCTUREGEOMETRYDESCRIPTOR_H_
#define _METAL_MTLACCELERATIONSTRUCTUREGEOMETRYDESCRIPTOR_H_

#import <Foundation/Foundation.h>

#import <Metal/MTLAccelerationStructure.h>
#import <Metal/MTLDefines.h>
#import <Metal/MTLRenderCommandEncoder.h>
#import <Metal/MTLStageInputOutputDescriptor.h>
METAL_DECLARATIONS_BEGIN


typedef NS_ENUM(NSInteger, MTLCurveType) {
	MTLCurveTypeRound = 0,
	MTLCurveTypeFlat = 1,
};

typedef NS_ENUM(NSInteger, MTLCurveBasis) {
	MTLCurveBasisBSpline = 0,
	MTLCurveBasisCatmullRom = 1,
	MTLCurveBasisLinear = 2,
	MTLCurveBasisBezier = 3,
};

typedef NS_ENUM(NSInteger, MTLCurveEndCaps) {
	MTLCurveEndCapsNone = 0,
	MTLCurveEndCapsDisk = 1,
	MTLCurveEndCapsSphere = 2,
};

/**
 * Describes one kind of geometry going into an acceleration structure.
 *
 * This whole family is stored and handed back unchanged, so a caller that reads
 * a geometry descriptor back out of an array gets the same values and the same
 * identity it put in. The discriminator property that names a subclass is not
 * declared: its enumerators are in none of the references available here, and a
 * subclass marker invented to fill the gap would be a wrong answer wearing a
 * right shape.
 *
 * None of it can be turned into a structure. indium has no ray tracing, no
 * BLAS or TLAS, no shader binding table and no build or refit call, so
 * -[MTLDevice newAccelerationStructureWithDescriptor:error:] and
 * -buildAccelerationStructure:... are not declared. A caller that assembles
 * these and asks for a structure is told at the call that the feature is
 * missing, rather than receiving a structure that traces nothing.
 */
MTL_EXPORT
@interface MTLAccelerationStructureGeometryDescriptor : NSObject <NSCopying>
@end

@interface MTLAccelerationStructureTriangleGeometryDescriptor : MTLAccelerationStructureGeometryDescriptor

@property(nullable, nonatomic, retain) id<MTLBuffer> vertexBuffer;
@property(nonatomic) NSUInteger vertexBufferOffset;
@property(nonatomic) NSUInteger vertexStride;
@property(nonatomic) MTLAttributeFormat vertexFormat;
@property(nullable, nonatomic, retain) id<MTLBuffer> indexBuffer;
@property(nonatomic) NSUInteger indexBufferOffset;
@property(nonatomic) MTLIndexType indexType;
@property(nonatomic) NSUInteger triangleCount;
@property(nullable, nonatomic, retain) id<MTLBuffer> transformationMatrixBuffer;
@property(nonatomic) NSUInteger transformationMatrixBufferOffset;
@property(nonatomic) MTLMatrixLayout transformationMatrixLayout;

@end

@interface MTLAccelerationStructureBoundingBoxGeometryDescriptor : MTLAccelerationStructureGeometryDescriptor

@property(nullable, nonatomic, retain) id<MTLBuffer> boundingBoxBuffer;
@property(nonatomic) NSUInteger boundingBoxBufferOffset;
@property(nonatomic) NSUInteger boundingBoxStride;
@property(nonatomic) NSUInteger boundingBoxCount;

@end

@interface MTLAccelerationStructureMotionTriangleGeometryDescriptor : MTLAccelerationStructureGeometryDescriptor

@property(nullable, nonatomic, retain) NSArray<id<MTLBuffer>>* vertexBuffers;
@property(nonatomic) NSUInteger vertexStride;
@property(nonatomic) MTLAttributeFormat vertexFormat;
@property(nullable, nonatomic, retain) id<MTLBuffer> indexBuffer;
@property(nonatomic) NSUInteger indexBufferOffset;
@property(nonatomic) MTLIndexType indexType;
@property(nonatomic) NSUInteger triangleCount;
@property(nullable, nonatomic, retain) id<MTLBuffer> transformationMatrixBuffer;
@property(nonatomic) NSUInteger transformationMatrixBufferOffset;
@property(nonatomic) MTLMatrixLayout transformationMatrixLayout;

@end

@interface MTLAccelerationStructureMotionBoundingBoxGeometryDescriptor : MTLAccelerationStructureGeometryDescriptor

@property(nullable, nonatomic, retain) NSArray<id<MTLBuffer>>* boundingBoxBuffers;
@property(nonatomic) NSUInteger boundingBoxStride;
@property(nonatomic) NSUInteger boundingBoxCount;

@end

@interface MTLAccelerationStructureCurveGeometryDescriptor : MTLAccelerationStructureGeometryDescriptor

@property(nullable, nonatomic, retain) id<MTLBuffer> controlPointBuffer;
@property(nonatomic) NSUInteger controlPointBufferOffset;
@property(nonatomic) NSUInteger controlPointStride;
@property(nonatomic) MTLAttributeFormat controlPointFormat;
@property(nonatomic) NSUInteger controlPointCount;
@property(nullable, nonatomic, retain) id<MTLBuffer> radiusBuffer;
@property(nonatomic) NSUInteger radiusBufferOffset;
@property(nonatomic) NSUInteger radiusStride;
@property(nonatomic) MTLAttributeFormat radiusFormat;
@property(nullable, nonatomic, retain) id<MTLBuffer> indexBuffer;
@property(nonatomic) NSUInteger indexBufferOffset;
@property(nonatomic) MTLIndexType indexType;
@property(nonatomic) NSUInteger segmentCount;
@property(nonatomic) NSUInteger segmentControlPointCount;
@property(nonatomic) MTLCurveType curveType;
@property(nonatomic) MTLCurveBasis curveBasis;
@property(nonatomic) MTLCurveEndCaps curveEndCaps;

@end

@interface MTLAccelerationStructureMotionCurveGeometryDescriptor : MTLAccelerationStructureGeometryDescriptor

@property(nullable, nonatomic, retain) NSArray<id<MTLBuffer>>* controlPointBuffers;
@property(nonatomic) NSUInteger controlPointStride;
@property(nonatomic) MTLAttributeFormat controlPointFormat;
@property(nonatomic) NSUInteger controlPointCount;
@property(nullable, nonatomic, retain) NSArray<id<MTLBuffer>>* radiusBuffers;
@property(nonatomic) NSUInteger radiusStride;
@property(nonatomic) MTLAttributeFormat radiusFormat;
@property(nullable, nonatomic, retain) id<MTLBuffer> indexBuffer;
@property(nonatomic) NSUInteger indexBufferOffset;
@property(nonatomic) MTLIndexType indexType;
@property(nonatomic) NSUInteger segmentCount;
@property(nonatomic) NSUInteger segmentControlPointCount;
@property(nonatomic) MTLCurveType curveType;
@property(nonatomic) MTLCurveBasis curveBasis;
@property(nonatomic) MTLCurveEndCaps curveEndCaps;

@end

METAL_DECLARATIONS_END

#endif // _METAL_MTLACCELERATIONSTRUCTUREGEOMETRYDESCRIPTOR_H_
