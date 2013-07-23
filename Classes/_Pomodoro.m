// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Pomodoro.m instead.

#import "_Pomodoro.h"

@implementation PomodoroID
@end

@implementation _Pomodoro

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Pomodoro" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Pomodoro";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Pomodoro" inManagedObjectContext:moc_];
}

- (PomodoroID*)objectID {
	return (PomodoroID*)[super objectID];
}




@dynamic task;

	





@end
