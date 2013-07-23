// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to LongBreak.h instead.

#import <CoreData/CoreData.h>
#import "WorkUnit.h"

@class Task;


@interface LongBreakID : NSManagedObjectID {}
@end

@interface _LongBreak : WorkUnit {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (LongBreakID*)objectID;




@property (nonatomic, retain) Task* task;
//- (BOOL)validateTask:(id*)value_ error:(NSError**)error_;




@end

@interface _LongBreak (CoreDataGeneratedAccessors)

@end

@interface _LongBreak (CoreDataGeneratedPrimitiveAccessors)



- (Task*)primitiveTask;
- (void)setPrimitiveTask:(Task*)value;


@end
