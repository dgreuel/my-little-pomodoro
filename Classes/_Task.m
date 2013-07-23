// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Task.m instead.

#import "_Task.h"

@implementation TaskID
@end

@implementation _Task

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Task";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Task" inManagedObjectContext:moc_];
}

- (TaskID*)objectID {
	return (TaskID*)[super objectID];
}




@dynamic isVisible;



- (BOOL)isVisibleValue {
	NSNumber *result = [self isVisible];
	return [result boolValue];
}

- (void)setIsVisibleValue:(BOOL)value_ {
	[self setIsVisible:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsVisibleValue {
	NSNumber *result = [self primitiveIsVisible];
	return [result boolValue];
}

- (void)setPrimitiveIsVisibleValue:(BOOL)value_ {
	[self setPrimitiveIsVisible:[NSNumber numberWithBool:value_]];
}





@dynamic name;






@dynamic creationDate;






@dynamic isCompleted;



- (BOOL)isCompletedValue {
	NSNumber *result = [self isCompleted];
	return [result boolValue];
}

- (void)setIsCompletedValue:(BOOL)value_ {
	[self setIsCompleted:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsCompletedValue {
	NSNumber *result = [self primitiveIsCompleted];
	return [result boolValue];
}

- (void)setPrimitiveIsCompletedValue:(BOOL)value_ {
	[self setPrimitiveIsCompleted:[NSNumber numberWithBool:value_]];
}





@dynamic longBreaks;

	
- (NSMutableSet*)longBreaksSet {
	[self willAccessValueForKey:@"longBreaks"];
	NSMutableSet *result = [self mutableSetValueForKey:@"longBreaks"];
	[self didAccessValueForKey:@"longBreaks"];
	return result;
}
	

@dynamic shortBreaks;

	
- (NSMutableSet*)shortBreaksSet {
	[self willAccessValueForKey:@"shortBreaks"];
	NSMutableSet *result = [self mutableSetValueForKey:@"shortBreaks"];
	[self didAccessValueForKey:@"shortBreaks"];
	return result;
}
	

@dynamic pomodoros;

	
- (NSMutableSet*)pomodorosSet {
	[self willAccessValueForKey:@"pomodoros"];
	NSMutableSet *result = [self mutableSetValueForKey:@"pomodoros"];
	[self didAccessValueForKey:@"pomodoros"];
	return result;
}
	



@dynamic completedLongBreaks;

@dynamic completedPomodoros;

@dynamic completedShortBreaks;



@end
