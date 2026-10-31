// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#include <assert.h>
#include <stdio.h>
#ifdef NDEBUG
#error Assertions required
#endif
@protocol StageShape <NSObject, NSCopying>
+ (instancetype)stageInputOutputDescriptor;
@property(readonly) id attributes;
@property(readonly) id layouts;
@property NSUInteger indexBufferIndex;
@property MTLIndexType indexType;
- (void)reset;
@end
@protocol AttributeShape <NSObject, NSCopying>
@property MTLAttributeFormat format;
@property NSUInteger offset;
@property NSUInteger bufferIndex;
@end
@protocol LayoutShape <NSObject, NSCopying>
@property NSUInteger stride;
@property NSUInteger stepFunction;
@property NSUInteger stepRate;
@end
@interface NSObject (StageArrayProbe)
- (id)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)index;
@end
static BOOL rejects(id array,NSUInteger index,id value,BOOL write) {
    @try {
        if(write)[array setObject:value atIndexedSubscript:index];
        else [array objectAtIndexedSubscript:index];
    } @catch(NSException *exception) {
        return [[exception name] isEqualToString:NSRangeException];
    }
    return NO;
}
int main(void) {
    @autoreleasepool {
        setbuf(stdout,NULL);puts("ENTER Metal stage-input data descriptor fixture");
        assert(NSClassFromString(@"MTLComputePipelineDescriptor")!=Nil);
        NSArray *classes=@[@"MTLStageInputOutputDescriptor",@"MTLAttributeDescriptor",@"MTLBufferLayoutDescriptor",@"MTLAttributeDescriptorArray",@"MTLBufferLayoutDescriptorArray"];
        for(NSString *name in classes) {
            printf("CLASS %s\n",[name UTF8String]);
            assert(NSClassFromString(name)!=Nil);
        }
        id<StageShape> stage=[(id)NSClassFromString(@"MTLStageInputOutputDescriptor") stageInputOutputDescriptor];
        assert(stage && stage.attributes && stage.layouts);
        id<AttributeShape> attribute=[stage.attributes objectAtIndexedSubscript:2];
        id<LayoutShape> layout=[stage.layouts objectAtIndexedSubscript:3];
        assert(attribute.format==MTLAttributeFormatInvalid && attribute.offset==0 && attribute.bufferIndex==0);
        // Defaults are the documented conservative Indium policy, not observed Mac values.
        assert(layout.stride==0 && layout.stepFunction==2 && layout.stepRate==1);
        assert(stage.indexBufferIndex==0 && stage.indexType==MTLIndexTypeUInt16);
        attribute.format=MTLAttributeFormatFloat3;attribute.offset=12;attribute.bufferIndex=3;
        layout.stride=32;layout.stepFunction=7;layout.stepRate=4;
        stage.indexBufferIndex=5;stage.indexType=MTLIndexTypeUInt32;
        id<StageShape> copy=[stage copyWithZone:NULL];
        id<AttributeShape> copiedAttribute=[copy.attributes objectAtIndexedSubscript:2];
        id<LayoutShape> copiedLayout=[copy.layouts objectAtIndexedSubscript:3];
        assert(copiedAttribute!=attribute && copiedLayout!=layout);
        assert(copiedAttribute.format==MTLAttributeFormatFloat3 && copiedAttribute.offset==12 && copiedAttribute.bufferIndex==3);
        assert(copiedLayout.stride==32 && copiedLayout.stepFunction==7 && copiedLayout.stepRate==4);
        assert(copy.indexType==MTLIndexTypeUInt32 && copy.indexBufferIndex==5);
        attribute.offset=24;layout.stride=64;
        assert(copiedAttribute.offset==12 && copiedLayout.stride==32);
        MTLComputePipelineDescriptor *compute=[NSClassFromString(@"MTLComputePipelineDescriptor") new];
        compute.stageInputDescriptor=(id)stage;
        attribute.offset=48;
        assert(((id<AttributeShape>)[((id<StageShape>)compute.stageInputDescriptor).attributes objectAtIndexedSubscript:2]).offset==24);
        [compute reset];assert(compute.stageInputDescriptor==nil);[compute release];
        assert([stage.attributes objectAtIndexedSubscript:30]);
        assert([stage.layouts objectAtIndexedSubscript:30]);
        assert(rejects(stage.attributes,31,nil,NO) && rejects(stage.layouts,31,nil,YES));
        assert(rejects(stage.attributes,NSUIntegerMax,nil,NO));
        BOOL wrongType=NO;
        @try { [stage.attributes setObject:[[[NSObject alloc] init] autorelease] atIndexedSubscript:0]; }
        @catch(NSException *exception) { wrongType=[[exception name] isEqualToString:NSInvalidArgumentException]; }
        assert(wrongType);
        [stage.attributes setObject:nil atIndexedSubscript:2];
        assert(((id<AttributeShape>)[stage.attributes objectAtIndexedSubscript:2]).format==MTLAttributeFormatInvalid);
        [copy reset];
        assert(copy.indexType==MTLIndexTypeUInt16 && copy.indexBufferIndex==0);
        assert(((id<AttributeShape>)[copy.attributes objectAtIndexedSubscript:2]).offset==0);
        assert(((id<LayoutShape>)[copy.layouts objectAtIndexedSubscript:3]).stride==0);
        [copy release];
        puts("PASS: stage-input metadata, ownership, reset, deep copy and bounds without a GPU device");
    }
    return 0;
}
