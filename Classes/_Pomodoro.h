// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Pomodoro.h instead.

#import <CoreData/CoreData.h>
#import "WorkUnit.h"

@class Task;


@interface PomodoroID : NSManagedObjectID {}
@end

@interface _Pomodoro : WorkUnit {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PomodoroID*)objectID;




@property (nonatomic, retain) Task* task;
//- (BOOL)validateTask:(id*)value_ error:(NSError**)error_;




@end

@interface _Pomodoro (CoreDataGeneratedAccessors)

@end

@interface _Pomodoro (CoreDataGeneratedPrimitiveAccessors)



- (Task*)primitiveTask;
- (void)setPrimitiveTask:(Task*)value;


@end
