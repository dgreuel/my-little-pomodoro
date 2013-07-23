// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to LongBreak.m instead.

#import "_LongBreak.h"

@implementation LongBreakID
@end

@implementation _LongBreak

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"LongBreak" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"LongBreak";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"LongBreak" inManagedObjectContext:moc_];
}

- (LongBreakID*)objectID {
	return (LongBreakID*)[super objectID];
}




@dynamic task;

	





@end
