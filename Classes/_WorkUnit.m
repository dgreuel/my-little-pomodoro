// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WorkUnit.m instead.

#import "_WorkUnit.h"

@implementation WorkUnitID
@end

@implementation _WorkUnit

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"WorkUnit" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"WorkUnit";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"WorkUnit" inManagedObjectContext:moc_];
}

- (WorkUnitID*)objectID {
	return (WorkUnitID*)[super objectID];
}




@dynamic stops;



- (short)stopsValue {
	NSNumber *result = [self stops];
	return [result shortValue];
}

- (void)setStopsValue:(short)value_ {
	[self setStops:[NSNumber numberWithShort:value_]];
}

- (short)primitiveStopsValue {
	NSNumber *result = [self primitiveStops];
	return [result shortValue];
}

- (void)setPrimitiveStopsValue:(short)value_ {
	[self setPrimitiveStops:[NSNumber numberWithShort:value_]];
}





@dynamic beginDate;






@dynamic endDate;






@dynamic length;



- (double)lengthValue {
	NSNumber *result = [self length];
	return [result doubleValue];
}

- (void)setLengthValue:(double)value_ {
	[self setLength:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLengthValue {
	NSNumber *result = [self primitiveLength];
	return [result doubleValue];
}

- (void)setPrimitiveLengthValue:(double)value_ {
	[self setPrimitiveLength:[NSNumber numberWithDouble:value_]];
}









@end
