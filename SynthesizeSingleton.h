//
//  SynthesizeSingleton.h
//
//  Adapted from Matt Gallagher's (CocoaWithLove) work, see
//  http://cocoawithlove.com/2008/11/singletons-appdelegates-and-top-level.html
//

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
 \
+ (classname *)sharedInstance \
{ \
  static classname *sharedInstance = nil; \
 \
  if (!sharedInstance) \
  { \
    sharedInstance = [[super allocWithZone:NULL] init]; \
  } \
 \
	return sharedInstance; \
} \
 \
+ (id)allocWithZone:(NSZone *)zone \
{ \
  return [[self sharedInstance] retain]; \
 \
} \
 \
- (id)copyWithZone:(NSZone *)zone \
{ \
	return self; \
} \
 \
- (id)retain \
{ \
	return self; \
} \
 \
- (NSUInteger)retainCount \
{ \
	return NSUIntegerMax; \
} \
 \
- (void)release \
{ \
} \
 \
- (id)autorelease \
{ \
	return self; \
}
