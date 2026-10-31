// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0

#import <Metal/MTLCounterSampleBufferInternal.h>

#if __LP64__


@implementation MTLCounterSampleBufferDescriptor

@synthesize label = _label;
@synthesize counterSet = _counterSet;
@synthesize storageMode = _storageMode;
@synthesize sampleCount = _sampleCount;

- (void)dealloc
{
	[_label release];
	[(id)_counterSet release];
	[super dealloc];
}

- (id)copyWithZone: (NSZone*)zone
{
	MTLCounterSampleBufferDescriptor* copy =
		[[MTLCounterSampleBufferDescriptor allocWithZone: zone] init];

	copy.label = _label;
	copy.counterSet = _counterSet;
	copy.storageMode = _storageMode;
	copy.sampleCount = _sampleCount;

	return copy;
}

@end

#if DARLING_METAL_ENABLED

@interface MTLTimestampCounterInternal : NSObject <MTLCounter>
@end
@implementation MTLTimestampCounterInternal
- (NSString*)name { return MTLCommonCounterTimestamp; }
@end

@implementation MTLTimestampCounterSetInternal
@synthesize device = _device;
- (instancetype)initWithDevice:(id<MTLDevice>)device
{
	if ((self = [super init])) _device = [device retain];
	return self;
}
- (void)dealloc { [_device release]; [super dealloc]; }
- (NSString*)name { return MTLCommonCounterSetTimestamp; }
- (NSArray<id<MTLCounter>>*)counters { return @[[[[MTLTimestampCounterInternal alloc] init] autorelease]]; }
@end

@implementation MTLCounterSampleBufferInternal
@synthesize buffer = _buffer;
@synthesize device = _device;
@synthesize label = _label;
- (instancetype)initWithBuffer:(std::shared_ptr<Indium::CounterSampleBuffer>)buffer
                        device:(id<MTLDevice>)device label:(NSString*)label
{
	if ((self = [super init])) {
		_buffer = buffer;
		_device = [device retain];
		_label = [label copy];
	}
	return self;
}
- (void)dealloc { [_device release]; [_label release]; [super dealloc]; }
- (NSUInteger)sampleCount { return _buffer->sampleCount(); }
- (NSData*)resolveCounterRange:(NSRange)range
{
	if (range.location > self.sampleCount || range.length > self.sampleCount - range.location)
		[NSException raise:NSRangeException format:@"Invalid timestamp counter resolve range"];
	try {
		auto bytes = _buffer->resolveCounterRange({range.location, range.length});
		return [NSData dataWithBytes:bytes.data() length:bytes.size()];
	} catch (const std::exception&) {
		return nil;
	}
}
@end
#endif
#endif // __LP64__
