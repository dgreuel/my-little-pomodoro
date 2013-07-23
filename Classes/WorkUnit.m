//
// My Little Pomodoro
// Copyright (c) 2010-2013, Keith Whitney
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// * Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
// * Neither the name of the <organization> nor the
// names of its contributors may be used to endorse or promote products
// derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "WorkUnit.h"
#import "ModelController.h"

@implementation WorkUnit

/**
 * Returns a predicate that filters either completed or incomplete work units
 */
+ (NSPredicate *)completedPredicate:(BOOL)completed
{
  return (completed) ? [NSPredicate predicateWithFormat:@"endDate != nil"] : [NSPredicate predicateWithFormat:@"endDate == nil"];
}

/**
 * Returns a predicate that filters work units that are not in the given range
 */
+ (NSPredicate *)beginDatePredicateFrom:(NSDate *)from to:(NSDate *)to
{
  return [NSPredicate predicateWithFormat:@"%@ <= beginDate AND beginDate <= %@", from, to];
}

#pragma mark -
#pragma mark Statistics methods

/**
 * Returns the number of work units that satisfy the predicate
 */
+ (NSNumber *)countWithPredicate:(NSPredicate *)predicate
{
  NSManagedObjectContext *moc = [[ModelController sharedInstance] managedObjectContext];
  return [[ModelController sharedInstance] numberOfObjectsWithEntityDescription:[self entityInManagedObjectContext:moc] predicate:predicate];
}

/**
 * Returns the number of work units which began between the given dates
 */
+ (NSNumber *)countFrom:(NSDate *)from to:(NSDate *)to
{
  return [self countWithPredicate:[self beginDatePredicateFrom:from to:to]];
}

/**
 * Returns the number of work units that are completed or incomplete which began between the given dates
 */
+ (NSNumber *)countFrom:(NSDate *)from to:(NSDate *)to completed:(BOOL)completed
{
  NSPredicate *datePredicate = [self beginDatePredicateFrom:from to:to];
  NSPredicate *completedPredicate = [self completedPredicate:completed];
  NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:datePredicate, completedPredicate, nil]];
  
  return [self countWithPredicate:predicate];
}

/**
 * Returns the number of work units that are completed which began between the given dates
 */
+ (NSNumber *)countOfCompletedFrom:(NSDate *)from to:(NSDate *)to
{
  return [self countFrom:from to:to completed:YES];
}

/**
 * Returns the number of work units that are incomplete which began between the given dates
 */
+ (NSNumber *)countOfIncompleteFrom:(NSDate *)from to:(NSDate *)to
{
  return [self countFrom:from to:to completed:NO];
}

/**
 * Returns the sum of the minutes of the completed work units which began between the given dates
 */
+ (NSNumber *)completedMinutesFrom:(NSDate *)from to:(NSDate *)to
{
  NSPredicate *datePredicate = [self beginDatePredicateFrom:from to:to];
  NSPredicate *completedPredicate = [self completedPredicate:YES];
  NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:datePredicate, completedPredicate, nil]];
 
  NSManagedObjectContext *moc = [[ModelController sharedInstance] managedObjectContext];
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:[self entityInManagedObjectContext:moc]];
  [request setPredicate:predicate];
  
  NSError *error = nil;
  NSArray *workUnits = [moc executeFetchRequest:request error:&error];
  double minutes = (!error) ? [[workUnits valueForKeyPath:@"@sum.length"] doubleValue] / 60.0 : 0.0;
  
  return [NSNumber numberWithDouble:minutes];
}

/**
 * Returns a dictionary that contains
 * 1.) An array of dictionaries that contain an x and y value representing the date and number of completed work units, respectively.
 * dateComponent and calendarUnit define the breakdown (hour, day, week, month, etc.) of the data.
 * 2.) A maximum value for the y values.
 */
+ (NSDictionary *)tabularCompletedFrom:(NSDate *)from to:(NSDate *)to calendar:(NSCalendar *)calendar calendarUnit:(NSCalendarUnit)calendarUnit dateComponent:(NSDateComponents *)dateComponent
{ 
  NSMutableArray *rows = [NSMutableArray array];
  NSNumber *maxY = [NSNumber numberWithInteger:NSIntegerMin];
  
  NSDate *date = from;
  while ([date compare:to] == NSOrderedAscending)
  {
    // Get the length of the date in the given calendar unit
    NSTimeInterval timeInterval = 0;
    [calendar rangeOfUnit:calendarUnit startDate:nil interval:&timeInterval forDate:date];
    
    NSDate *xValue = date;
    NSNumber *yValue = [self countOfCompletedFrom:date to:[date dateByAddingTimeInterval:timeInterval - 1]];
    [rows addObject:[NSDictionary dictionaryWithObjectsAndKeys:xValue, kXValueKey, yValue, kYValueKey, nil]];
    
    // Find the maximum yValue
    if ([maxY compare:yValue] == NSOrderedAscending)
      maxY = yValue;
    
    date = [calendar dateByAddingComponents:dateComponent toDate:date options:0];
  }
  
  return [NSDictionary dictionaryWithObjectsAndKeys:rows, kDataKey, maxY, kMaxYKey, nil];
}

/**
 * See tabularCompletedFrom:to:calendar:calendarUnit:dateComponent for reference.
 */
+ (NSDictionary *)tabularDailyCompletedFrom:(NSDate *)from to:(NSDate *)to calendar:(NSCalendar *)calendar
{
  NSDateComponents *oneDay = [[NSDateComponents alloc] init];
  [oneDay setDay:1];
  
  return [self tabularCompletedFrom:from to:to calendar:calendar calendarUnit:NSDayCalendarUnit dateComponent:oneDay];
}

/**
 * See tabularCompletedFrom:to:calendar:calendarUnit:dateComponent for reference.
 */
+ (NSDictionary *)tabularHourlyCompletedFrom:(NSDate *)from to:(NSDate *)to calendar:(NSCalendar *)calendar
{
  NSDateComponents *oneHour = [[NSDateComponents alloc] init];
  [oneHour setHour:1];
  
  return [self tabularCompletedFrom:from to:to calendar:calendar calendarUnit:NSHourCalendarUnit dateComponent:oneHour];
}

#pragma mark -

/**
 * Returns a string representing the type of work unit
 */
- (NSString *)typeOfWorkUnit
{
  return @"Work Unit";
}

/**
 * Returns the length of the work unit in minutes
 */
- (NSNumber *)lengthInMinutes
{
  double lengthInSeconds = [[self length] doubleValue];
  return [NSNumber numberWithDouble:(lengthInSeconds / 60.0)];
}

@end
