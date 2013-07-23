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

#import "Task.h"
#import "ModelController.h"

@implementation Task

/**
 * Returns a predicate that filters either visible or invisible tasks
 */
+ (NSPredicate *)visiblePredicate:(BOOL)visible
{
  return [NSPredicate predicateWithFormat:@"isVisible == %@", [NSNumber numberWithBool:visible]];
}

/**
 * Returns a predicate that filters either completed or incomplete tasks
 */
+ (NSPredicate *)completedPredicate:(BOOL)completed
{
  return [NSPredicate predicateWithFormat:@"isCompleted == %@", [NSNumber numberWithBool:completed]];
}

/**
 * Returns a predicate that filters creation dates that are not in the given range
 */
+ (NSPredicate *)creationDatePredicateFrom:(NSDate *)from to:(NSDate *)to
{
  return [NSPredicate predicateWithFormat:@"%@ <= creationDate AND creationDate <= %@", from, to];
}

#pragma mark -
#pragma mark Statistics methods

/**
 * Returns the number of tasks with the given predicate
 */
+ (NSNumber *)numberOfTasksWithPredicate:(NSPredicate *)predicate
{
  NSManagedObjectContext *moc = [[ModelController sharedInstance] managedObjectContext];
  return [[ModelController sharedInstance] numberOfObjectsWithEntityDescription:[Task entityInManagedObjectContext:moc] predicate:predicate];
}

/**
 * Returns the number of tasks that fall within the given date range
 */
+ (NSNumber *)numberOfTasksFrom:(NSDate *)from to:(NSDate *)to
{
  return [Task numberOfTasksWithPredicate:[Task creationDatePredicateFrom:from to:to]];
}

/**
 * Returns the number of tasks that fall within the given date range that are either completed or incomplete
 */
+ (NSNumber *)numberOfTasksFrom:(NSDate *)from to:(NSDate *)to completed:(BOOL)completed
{
  NSPredicate *datePredicate = [Task creationDatePredicateFrom:from to:to];
  NSPredicate *completedPredicate = [Task completedPredicate:completed];
  NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:datePredicate, completedPredicate, nil]];
  
  return [Task numberOfTasksWithPredicate:predicate];
}

/**
 * Returns the number of completed tasks that fall within the given date range
 */
+ (NSNumber *)numberOfCompletedTasksFrom:(NSDate *)from to:(NSDate *)to
{
  return [Task numberOfTasksFrom:from to:to completed:YES];
}

/**
 * Returns the number of incomplete tasks that fall within the given date range
 */
+ (NSNumber *)numberOfIncompleteTasksFrom:(NSDate *)from to:(NSDate *)to
{
  return [Task numberOfTasksFrom:from to:to completed:NO];
}

#pragma mark -

/**
 * Returns the number of completed pomodoros
 */
- (NSNumber *)numberOfCompletedPomodoros
{
  return [NSNumber numberWithInt:[[self completedPomodoros] count]];
}

/**
 * Returns the sum of the lengths (in minutes) of the completed pomodoros
 */
- (NSNumber *)totalCompletedPomodoroMinutes
{
  double totalSeconds = [[[self completedPomodoros] valueForKeyPath:@"@sum.length"] doubleValue];
  return [NSNumber numberWithDouble:(totalSeconds / 60.0)];
}

/**
 * Returns the number of stops for all of the pomodoros related to this task
 */
- (NSNumber *)numberOfPomodoroStops
{
  return [[self pomodoros] valueForKeyPath:@"@sum.stops"];
}

#pragma mark -

/**
 * Returns the number of completed short breaks
 */
- (NSNumber *)numberOfCompletedShortBreaks
{
  return [NSNumber numberWithInt:[[self completedShortBreaks] count]];
}

/**
 * Returns the sum of the lengths (in minutes) of the completed short breaks
 */
- (NSNumber *)totalCompletedShortBreakMinutes
{
  double totalSeconds = [[[self completedShortBreaks] valueForKeyPath:@"@sum.length"] doubleValue];
  return [NSNumber numberWithDouble:(totalSeconds / 60.0)];
}

/**
 * Returns the number of stops for all of the short breaks related to this task
 */
- (NSNumber *)numberOfShortBreakStops
{
  return [[self shortBreaks] valueForKeyPath:@"@sum.stops"];
}

#pragma mark -

/**
 * Returns the number of completed long breaks
 */
- (NSNumber *)numberOfCompletedLongBreaks
{
  return [NSNumber numberWithInt:[[self completedLongBreaks] count]];
}

/**
 * Returns the sum of the lengths (in minutes) of the completed long breaks
 */
- (NSNumber *)totalCompletedLongBreakMinutes
{
  double totalSeconds = [[[self completedLongBreaks] valueForKeyPath:@"@sum.length"] doubleValue];
  return [NSNumber numberWithDouble:(totalSeconds / 60.0)];
}

/**
 * Returns the number of stops for all of the long breaks related to this task
 */
- (NSNumber *)numberOfLongBreakStops
{
  return [[self longBreaks] valueForKeyPath:@"@sum.stops"];
}


#pragma mark -

- (void)awakeFromInsert 
{
	[self setCreationDate:[NSDate date]];
}

@end
