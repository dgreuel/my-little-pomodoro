// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to WorkUnit.h instead.

#import <CoreData/CoreData.h>








@interface WorkUnitID : NSManagedObjectID {}
@end

@interface _WorkUnit : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (WorkUnitID*)objectID;



@property (nonatomic, retain) NSNumber *stops;

@property short stopsValue;
- (short)stopsValue;
- (void)setStopsValue:(short)value_;

//- (BOOL)validateStops:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *beginDate;

//- (BOOL)validateBeginDate:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *endDate;

//- (BOOL)validateEndDate:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *length;

@property double lengthValue;
- (double)lengthValue;
- (void)setLengthValue:(double)value_;

//- (BOOL)validateLength:(id*)value_ error:(NSError**)error_;





@end

@interface _WorkUnit (CoreDataGeneratedAccessors)

@end

@interface _WorkUnit (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveStops;
- (void)setPrimitiveStops:(NSNumber*)value;

- (short)primitiveStopsValue;
- (void)setPrimitiveStopsValue:(short)value_;


- (NSDate*)primitiveBeginDate;
- (void)setPrimitiveBeginDate:(NSDate*)value;


- (NSDate*)primitiveEndDate;
- (void)setPrimitiveEndDate:(NSDate*)value;


- (NSNumber*)primitiveLength;
- (void)setPrimitiveLength:(NSNumber*)value;

- (double)primitiveLengthValue;
- (void)setPrimitiveLengthValue:(double)value_;



@end
