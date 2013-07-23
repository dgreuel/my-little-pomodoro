// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Task.h instead.

#import <CoreData/CoreData.h>


@class LongBreak;
@class ShortBreak;
@class Pomodoro;






@interface TaskID : NSManagedObjectID {}
@end

@interface _Task : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TaskID*)objectID;



@property (nonatomic, retain) NSNumber *isVisible;

@property BOOL isVisibleValue;
- (BOOL)isVisibleValue;
- (void)setIsVisibleValue:(BOOL)value_;

//- (BOOL)validateIsVisible:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *creationDate;

//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *isCompleted;

@property BOOL isCompletedValue;
- (BOOL)isCompletedValue;
- (void)setIsCompletedValue:(BOOL)value_;

//- (BOOL)validateIsCompleted:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* longBreaks;
- (NSMutableSet*)longBreaksSet;



@property (nonatomic, retain) NSSet* shortBreaks;
- (NSMutableSet*)shortBreaksSet;



@property (nonatomic, retain) NSSet* pomodoros;
- (NSMutableSet*)pomodorosSet;




@property (nonatomic, readonly) NSArray *completedLongBreaks;

@property (nonatomic, readonly) NSArray *completedPomodoros;

@property (nonatomic, readonly) NSArray *completedShortBreaks;

@end

@interface _Task (CoreDataGeneratedAccessors)

- (void)addLongBreaks:(NSSet*)value_;
- (void)removeLongBreaks:(NSSet*)value_;
- (void)addLongBreaksObject:(LongBreak*)value_;
- (void)removeLongBreaksObject:(LongBreak*)value_;

- (void)addShortBreaks:(NSSet*)value_;
- (void)removeShortBreaks:(NSSet*)value_;
- (void)addShortBreaksObject:(ShortBreak*)value_;
- (void)removeShortBreaksObject:(ShortBreak*)value_;

- (void)addPomodoros:(NSSet*)value_;
- (void)removePomodoros:(NSSet*)value_;
- (void)addPomodorosObject:(Pomodoro*)value_;
- (void)removePomodorosObject:(Pomodoro*)value_;

@end

@interface _Task (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveIsVisible;
- (void)setPrimitiveIsVisible:(NSNumber*)value;

- (BOOL)primitiveIsVisibleValue;
- (void)setPrimitiveIsVisibleValue:(BOOL)value_;


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;


- (NSDate*)primitiveCreationDate;
- (void)setPrimitiveCreationDate:(NSDate*)value;


- (NSNumber*)primitiveIsCompleted;
- (void)setPrimitiveIsCompleted:(NSNumber*)value;

- (BOOL)primitiveIsCompletedValue;
- (void)setPrimitiveIsCompletedValue:(BOOL)value_;




- (NSMutableSet*)primitiveLongBreaks;
- (void)setPrimitiveLongBreaks:(NSMutableSet*)value;



- (NSMutableSet*)primitiveShortBreaks;
- (void)setPrimitiveShortBreaks:(NSMutableSet*)value;



- (NSMutableSet*)primitivePomodoros;
- (void)setPrimitivePomodoros:(NSMutableSet*)value;


@end
