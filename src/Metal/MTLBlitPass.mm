// SPDX-FileCopyrightText: 2026 Darling Developers
// SPDX-License-Identifier: MPL-2.0
#import <Metal/MTLBlitPassInternal.h>

#if __LP64__

// Four slots cover the single implemented timestamp counter set.
// Stage-boundary sampling remains unsupported.
static const NSUInteger MTLBlitSampleAttachmentCount = 4;

static void checkAttachmentIndex(NSUInteger index)
{
	if (index >= MTLBlitSampleAttachmentCount)
		[NSException raise:NSRangeException format:@"Metal blit sample attachment index %lu exceeds %lu slots",
			(unsigned long)index, (unsigned long)MTLBlitSampleAttachmentCount];
}

@interface MTLBlitPassSampleBufferAttachmentDescriptorArray (Storage) <NSCopying>
- (void)validateNoCounterSampling;
@end

@implementation MTLBlitPassSampleBufferAttachmentDescriptor
@synthesize sampleBuffer = _sampleBuffer;
@synthesize startOfEncoderSampleIndex = _startOfEncoderSampleIndex;
@synthesize endOfEncoderSampleIndex = _endOfEncoderSampleIndex;

- (instancetype)init
{
	if ((self = [super init])) {
		_startOfEncoderSampleIndex = MTLCounterDontSample;
		_endOfEncoderSampleIndex = MTLCounterDontSample;
	}
	return self;
}

- (void)dealloc
{
	[(id)_sampleBuffer release];
	[super dealloc];
}

- (id)copyWithZone:(NSZone*)zone
{
	MTLBlitPassSampleBufferAttachmentDescriptor* result = [[[self class] allocWithZone:zone] init];
	result.sampleBuffer = _sampleBuffer;
	result.startOfEncoderSampleIndex = _startOfEncoderSampleIndex;
	result.endOfEncoderSampleIndex = _endOfEncoderSampleIndex;
	return result;
}
@end

@implementation MTLBlitPassSampleBufferAttachmentDescriptorArray
{
	MTLBlitPassSampleBufferAttachmentDescriptor* _attachments[MTLBlitSampleAttachmentCount];
}

- (void)dealloc
{
	for (NSUInteger i = 0; i < MTLBlitSampleAttachmentCount; ++i)
		[_attachments[i] release];
	[super dealloc];
}

- (MTLBlitPassSampleBufferAttachmentDescriptor*)objectAtIndexedSubscript:(NSUInteger)index
{
	checkAttachmentIndex(index);
	if (_attachments[index] == nil)
		_attachments[index] = [MTLBlitPassSampleBufferAttachmentDescriptor new];
	return [[_attachments[index] retain] autorelease];
}

- (void)setObject:(MTLBlitPassSampleBufferAttachmentDescriptor*)attachment atIndexedSubscript:(NSUInteger)index
{
	checkAttachmentIndex(index);
	if (attachment != nil && ![attachment isKindOfClass:[MTLBlitPassSampleBufferAttachmentDescriptor class]])
		[NSException raise:NSInvalidArgumentException format:@"Expected a Metal blit sample attachment descriptor"];
	MTLBlitPassSampleBufferAttachmentDescriptor* target = [self objectAtIndexedSubscript:index];
	target.sampleBuffer = attachment.sampleBuffer;
	target.startOfEncoderSampleIndex = attachment != nil ? attachment.startOfEncoderSampleIndex : MTLCounterDontSample;
	target.endOfEncoderSampleIndex = attachment != nil ? attachment.endOfEncoderSampleIndex : MTLCounterDontSample;
}

- (id)copyWithZone:(NSZone*)zone
{
	MTLBlitPassSampleBufferAttachmentDescriptorArray* result = [[[self class] allocWithZone:zone] init];
	for (NSUInteger i = 0; i < MTLBlitSampleAttachmentCount; ++i)
		result->_attachments[i] = [_attachments[i] copyWithZone:zone];
	return result;
}

- (void)validateNoCounterSampling
{
	for (NSUInteger i = 0; i < MTLBlitSampleAttachmentCount; ++i) {
		if (_attachments[i].sampleBuffer != nil)
			[NSException raise:NSInternalInconsistencyException
				format:@"Metal blit pass counter sampling is unsupported: stage-boundary sampling is not implemented"];
	}
}
@end

@implementation MTLBlitPassDescriptor
@synthesize sampleBufferAttachments = _sampleBufferAttachments;

+ (MTLBlitPassDescriptor*)blitPassDescriptor
{
	return [[[self alloc] init] autorelease];
}

- (instancetype)init
{
	if ((self = [super init]))
		_sampleBufferAttachments = [MTLBlitPassSampleBufferAttachmentDescriptorArray new];
	return self;
}

- (void)dealloc
{
	[_sampleBufferAttachments release];
	[super dealloc];
}

- (id)copyWithZone:(NSZone*)zone
{
	MTLBlitPassDescriptor* result = [[[self class] allocWithZone:zone] init];
	[result->_sampleBufferAttachments release];
	result->_sampleBufferAttachments = [_sampleBufferAttachments copyWithZone:zone];
	return result;
}
@end

#if DARLING_METAL_ENABLED
@implementation MTLBlitPassDescriptor (Internal)
- (Indium::BlitPassDescriptor)asIndiumDescriptor
{
	[_sampleBufferAttachments validateNoCounterSampling];
	return Indium::BlitPassDescriptor {};
}
@end
#endif
#endif
