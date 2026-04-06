#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "WelcomeScreenDark" asset catalog image resource.
static NSString * const ACImageNameWelcomeScreenDark AC_SWIFT_PRIVATE = @"WelcomeScreenDark";

/// The "WelcomeScreenLight" asset catalog image resource.
static NSString * const ACImageNameWelcomeScreenLight AC_SWIFT_PRIVATE = @"WelcomeScreenLight";

#undef AC_SWIFT_PRIVATE
