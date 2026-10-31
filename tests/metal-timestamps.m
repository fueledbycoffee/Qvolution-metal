#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
// Typed declarations also compile this unchanged fixture against the BEFORE headers.
@protocol TimestampCounter <NSObject>
@property(readonly) NSString* name;
@end
@protocol TimestampSet <NSObject>
@property(readonly) NSString* name;
@property(readonly) NSArray* counters;
@end
@protocol TimestampBuffer <NSObject>
@property(readonly) id<MTLDevice> device;
@property(readonly) NSUInteger sampleCount;
- (NSData*)resolveCounterRange:(NSRange)range;
@end
@protocol TimestampDevice <MTLDevice>
@property(readonly) NSArray* counterSets;
- (BOOL)supportsCounterSampling:(NSUInteger)point;
- (id<TimestampBuffer>)newCounterSampleBufferWithDescriptor:(MTLCounterSampleBufferDescriptor*)descriptor error:(NSError**)error;
@end
@protocol TimestampBlit <MTLBlitCommandEncoder>
- (void)sampleCountersInBuffer:(id<TimestampBuffer>)buffer atSampleIndex:(NSUInteger)index withBarrier:(BOOL)barrier;
@end
int main(void) {
 @autoreleasepool {
  id<TimestampDevice> device=(id)MTLCreateSystemDefaultDevice();
  assert(device);
  if (![device respondsToSelector:@selector(counterSets)] || ![device respondsToSelector:@selector(supportsCounterSampling:)]) {
   puts("BEFORE missing genuine counter capability API");return 42;
  }
  assert(![device supportsCounterSampling:0]); // unimplemented stage boundary
  assert(![device supportsCounterSampling:NSUIntegerMax]);
  NSArray* sets=device.counterSets;
  if (![device supportsCounterSampling:4]) { assert(sets.count==0);puts("UNSUPPORTED selected queue timestamps");return 77; }
  assert(sets.count==1);
  id<TimestampSet> set=[sets objectAtIndex:0];
  assert([set.name isEqual:MTLCommonCounterSetTimestamp]);
  assert(set.counters.count==1);
  assert([[(id<TimestampCounter>)[set.counters objectAtIndex:0] name] isEqual:MTLCommonCounterTimestamp]);
  MTLCounterSampleBufferDescriptor* desc=[MTLCounterSampleBufferDescriptor new];
  desc.counterSet=(id)set;desc.storageMode=MTLStorageModeShared;desc.sampleCount=3;
  NSError* error=nil;
  id<TimestampBuffer> samples=[device newCounterSampleBufferWithDescriptor:desc error:&error];
  assert(samples && !error && samples.device==device && samples.sampleCount==3);
  NSData* before=[samples resolveCounterRange:NSMakeRange(0,3)];assert(before.length==3*sizeof(uint64_t));
  const uint64_t* initial=before.bytes;assert(initial[0]==UINT64_MAX && initial[1]==UINT64_MAX && initial[2]==UINT64_MAX);
  id<MTLBuffer> work=[device newBufferWithLength:4096 options:MTLResourceStorageModeShared];assert(work);
  id<MTLCommandQueue> queue=[device newCommandQueue];assert(queue);
  id<MTLCommandBuffer> command=[queue commandBuffer];assert(command);
  id<TimestampBlit> blit=(id)[command blitCommandEncoder];assert(blit);
  [blit sampleCountersInBuffer:samples atSampleIndex:0 withBarrier:YES];
  [blit fillBuffer:work range:NSMakeRange(0,4096) value:0x5a];
  [blit sampleCountersInBuffer:samples atSampleIndex:1 withBarrier:YES];
  [blit endEncoding];
  NSData* pending=[samples resolveCounterRange:NSMakeRange(0,2)];
  const uint64_t* unavailable=pending.bytes;assert(unavailable[0]==UINT64_MAX && unavailable[1]==UINT64_MAX);
  [command commit];[command waitUntilCompleted];
  NSData* resolved=[samples resolveCounterRange:NSMakeRange(0,3)];assert(resolved.length==3*sizeof(uint64_t));
  const uint64_t* values=resolved.bytes;
  assert(values[0]!=UINT64_MAX && values[1]!=UINT64_MAX && values[2]==UINT64_MAX);
  const uint8_t* bytes=work.contents;for(NSUInteger i=0;i<4096;i++)assert(bytes[i]==0x5a);
  printf("PASS genuine timestamp query values %llu %llu; fill verified; unwritten sample unavailable\n",(unsigned long long)values[0],(unsigned long long)values[1]);
  [samples release];[desc release];[work release];[queue release];[device release];
 }
 return 0;
}
