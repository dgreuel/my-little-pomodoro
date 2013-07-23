// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ShortBreak.m instead.

#import "_ShortBreak.h"

@implementation ShortBreakID
@end

@implementation _ShortBreak

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ShortBreak" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ShortBreak";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ShortBreak" inManagedObjectContext:moc_];
}

- (ShortBreakID*)objectID {
	return (ShortBreakID*)[super objectID];
}




@dynamic task;

	





@end
