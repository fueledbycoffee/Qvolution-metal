// Published layout: apple/metal-cpp Metal/MTLCounters.hpp CounterResultTimestamp.
#import <Metal/MTLCounters.h>
#include <stddef.h>
_Static_assert(sizeof(MTLCounterResultTimestamp)==8,"timestamp result must occupy eight bytes");
_Static_assert(_Alignof(MTLCounterResultTimestamp)==1,"timestamp result must retain its published packed alignment");
_Static_assert(offsetof(MTLCounterResultTimestamp,timestamp)==0,"timestamp must begin the result");
struct TimestampEnvelope { char prefix; MTLCounterResultTimestamp sample; };
_Static_assert(offsetof(struct TimestampEnvelope,sample)==1,"packed result must not add enclosing padding");
_Static_assert(sizeof(struct TimestampEnvelope)==9,"packed result must retain its enclosing size");
