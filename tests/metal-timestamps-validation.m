#import <Metal/Metal.h>
#include <assert.h>
#include <stdio.h>

static void invalid(id<MTLDevice> device, MTLCounterSampleBufferDescriptor* descriptor) {
 NSError* error=nil;
 assert([device newCounterSampleBufferWithDescriptor:descriptor error:&error]==nil);
 assert(error && [error.domain isEqual:MTLCounterErrorDomain] && error.code==MTLCounterSampleBufferErrorInvalid);
 assert([device newCounterSampleBufferWithDescriptor:descriptor error:NULL]==nil);
}
int main(void) {
 @autoreleasepool {
  id<MTLDevice> device=MTLCreateSystemDefaultDevice();assert(device);
  if (![device supportsCounterSampling:MTLCounterSamplingPointAtBlitBoundary])return 77;
  MTLCounterSampleBufferDescriptor* desc=[MTLCounterSampleBufferDescriptor new];
  invalid(device,nil);invalid(device,desc);
  desc.counterSet=[device.counterSets objectAtIndex:0];
  invalid(device,desc); // zero count
  desc.sampleCount=1;desc.storageMode=MTLStorageModePrivate;invalid(device,desc);
  desc.storageMode=MTLStorageModeManaged;invalid(device,desc);
  desc.storageMode=MTLStorageModeShared;desc.sampleCount=NSUIntegerMax;invalid(device,desc);
  desc.sampleCount=1;
  NSObject* foreignSet=[NSObject new];desc.counterSet=(id)foreignSet;[foreignSet release];invalid(device,desc);
  desc.counterSet=[device.counterSets objectAtIndex:0];
  NSMutableString* label=[NSMutableString stringWithString:@"original"];
  desc.label=label;[label appendString:@" changed"];
  NSError* error=(id)desc;
  id<MTLCounterSampleBuffer> samples=[device newCounterSampleBufferWithDescriptor:desc error:&error];
  assert(samples && !error && [samples.label isEqual:@"original"]);
  BOOL rejected=NO;@try {[samples resolveCounterRange:NSMakeRange(1,1)];}@catch(NSException* exception){rejected=[exception.name isEqual:NSRangeException];}assert(rejected);
  id<MTLCommandQueue> queue=[device newCommandQueue];id<MTLCommandBuffer> command=[queue commandBuffer];id<MTLBlitCommandEncoder> blit=[command blitCommandEncoder];
  rejected=NO;@try {[blit sampleCountersInBuffer:samples atSampleIndex:MTLCounterDontSample withBarrier:NO];}@catch(NSException* exception){rejected=[exception.name isEqual:NSInvalidArgumentException];}assert(rejected);
  [blit sampleCountersInBuffer:samples atSampleIndex:0 withBarrier:NO];
  rejected=NO;@try {[blit sampleCountersInBuffer:samples atSampleIndex:0 withBarrier:NO];}@catch(NSException* exception){rejected=[exception.name isEqual:NSInvalidArgumentException];}assert(rejected);
  [blit endEncoding];
  rejected=NO;@try {[blit sampleCountersInBuffer:samples atSampleIndex:0 withBarrier:NO];}@catch(NSException* exception){rejected=[exception.name isEqual:NSInvalidArgumentException];}assert(rejected);
  [command commit];[command waitUntilCompleted];
  [samples release];[desc release];[queue release];[device release];
  puts("PASS invalid descriptor, storage, count, set, range, sentinel, in-flight reuse and ended encoder checks");
 }
 return 0;
}
