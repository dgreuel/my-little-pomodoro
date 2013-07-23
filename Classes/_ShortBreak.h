// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ShortBreak.h instead.

#import <CoreData/CoreData.h>
#import "WorkUnit.h"

@class Task;


@interface ShortBreakID : NSManagedObjectID {}
@end

@interface _ShortBreak : WorkUnit {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (ShortBreakID*)objectID;




@property (nonatomic, retain) Task* task;
//- (BOOL)validateTask:(id*)value_ error:(NSError**)error_;




@end

@interface _ShortBreak (CoreDataGeneratedAccessors)

@end

@interface _ShortBreak (CoreDataGeneratedPrimitiveAccessors)



- (Task*)primitiveTask;
- (void)setPrimitiveTask:(Task*)value;


@end
