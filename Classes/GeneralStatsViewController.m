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

#import "GeneralStatsViewController.h"
#import "ModelClasses.h"
#import "DayGraphViewController.h"
#import "WeekGraphViewController.h"
#import "MonthGraphViewController.h"
#import "GraphViewController.h"

@implementation GeneralStatsViewController

- (id)init
{
  if (self = [super initWithNibName:@"GeneralStatsView" bundle:nil]) 
  {
    graphViewController = nil;
    
    // Store the original statistics string (exactly how it was read from the RTF file)
    NSData *statsStringData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"GeneralStatisticsText" ofType:@"rtf"]];
    originalStatisticsString = [[NSAttributedString alloc] initWithRTF:statsStringData documentAttributes:nil];
    
    // Maps selectors to variables that will be replaced
    replacementDict = [NSDictionary dictionaryWithObjectsAndKeys:
                       @"numberOfTasks", @"%%total_tasks%%", 
                       @"numberOfCompletedTasks", @"%%completed_tasks%%",
                       @"numberOfIncompleteTasks", @"%%incomplete_tasks%%",
                       @"numberOfPomodoros", @"%%total_pomodoros%%",
                       @"numberOfCompletedPomodoros", @"%%completed_pomodoros%%",
                       @"numberOfIncompletePomodoros", @"%%incomplete_pomodoros%%",
                       @"completedPomodoroMinutes", @"%%completed_pomodoro_minutes%%",
                       @"numberOfShortBreaks", @"%%total_short_breaks%%",
                       @"numberOfCompletedShortBreaks", @"%%completed_short_breaks%%",
                       @"numberOfIncompleteShortBreaks", @"%%incomplete_short_breaks%%",
                       @"completedShortBreakMinutes", @"%%completed_short_break_minutes%%",
                       @"numberOfLongBreaks", @"%%total_long_breaks%%",
                       @"numberOfCompletedLongBreaks", @"%%completed_long_breaks%%",
                       @"numberOfIncompleteLongBreaks", @"%%incomplete_long_breaks%%",
                       @"completedLongBreakMinutes", @"%%completed_long_break_minutes%%",
                       nil];

    filterFrom = [NSDate date];
    filterTo = [NSDate date];
  }
  
  return self;
}

- (void)awakeFromNib
{
  // Set some padding on statsTextView
  [statsTextView setTextContainerInset:NSMakeSize(0, 2)];
  
  // TODO:  Remove this hack, as it's only a temporary solution.  The bottom half of the BWSplitView is really small when its outlet is set, and I have no clue why.
  [graphView setFrame:NSMakeRect(0, 0, [graphView frame].size.width, 9999)];
}

/**
 * Returns the string to be used in the top half of the view
 */
- (NSAttributedString *)statisticsString
{
  NSMutableAttributedString *statsString = [[NSMutableAttributedString alloc] initWithAttributedString:originalStatisticsString];

  // Replace each variable with the content returned by the selector
  for (NSString *key in replacementDict)
  {
    SEL selector = NSSelectorFromString([replacementDict objectForKey:key]);
    NSString *replacement = [[self performSelector:selector] stringValue];
    NSRange range = [[statsString string] rangeOfString:key];
    [statsString replaceCharactersInRange:range withString:replacement];
  }
  
  return statsString;
}

#pragma mark -

- (NSNumber *)numberOfTasks
{
  return [Task numberOfTasksFrom:filterFrom to:filterTo];
}

- (NSNumber *)numberOfCompletedTasks
{
  return [Task numberOfCompletedTasksFrom:filterFrom to:filterTo];
}

- (NSNumber *)numberOfIncompleteTasks
{
  return [Task numberOfIncompleteTasksFrom:filterFrom to:filterTo];
}

#pragma mark -

- (NSNumber *)numberOfPomodoros
{
  return [Pomodoro countFrom:filterFrom to:filterTo];
}

- (NSNumber *)numberOfCompletedPomodoros
{
  return [Pomodoro countOfCompletedFrom:filterFrom to:filterTo];
}

- (NSNumber *)numberOfIncompletePomodoros
{
  return [Pomodoro countOfIncompleteFrom:filterFrom to:filterTo];
}

- (NSNumber *)completedPomodoroMinutes
{
  return [Pomodoro completedMinutesFrom:filterFrom to:filterTo];
}

#pragma mark -

- (NSNumber *)numberOfShortBreaks
{
  return [ShortBreak countFrom:filterFrom to:filterTo];
}

- (NSNumber *)numberOfCompletedShortBreaks
{
  return [ShortBreak countOfCompletedFrom:filterFrom to:filterTo];
}

- (NSNumber *)numberOfIncompleteShortBreaks
{
  return [ShortBreak countOfIncompleteFrom:filterFrom to:filterTo];
}

- (NSNumber *)completedShortBreakMinutes
{
  return [ShortBreak completedMinutesFrom:filterFrom to:filterTo];
}

#pragma mark -

- (NSNumber *)numberOfLongBreaks
{
  return [LongBreak countFrom:filterFrom to:filterTo];
}

- (NSNumber *)numberOfCompletedLongBreaks
{
  return [LongBreak countOfCompletedFrom:filterFrom to:filterTo];
}

- (NSNumber *)numberOfIncompleteLongBreaks
{
  return [LongBreak countOfIncompleteFrom:filterFrom to:filterTo];
}

- (NSNumber *)completedLongBreakMinutes
{
  return [LongBreak completedMinutesFrom:filterFrom to:filterTo];
}


#pragma mark -
#pragma mark StatsViewController methods

- (void)filterContentFrom:(NSDate *)fromDate to:(NSDate *)toDate
{ 
  // If the fromDate or the toDate don't change, don't do anything.
  if ([filterFrom isEqual:fromDate] && [filterTo isEqual:toDate]) return;
  
  [self willChangeValueForKey:@"statisticsString"];
  
  filterFrom = fromDate;
  filterTo = toDate;
  
  [self didChangeValueForKey:@"statisticsString"];
  
  // Remove graphView's first subview, if it has subviews
  if ([[graphView subviews] count] > 1)
    [[[graphView subviews] objectAtIndex:1] removeFromSuperview];
  
  // How many days are between fromDate and toDate?
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSInteger days = [[calendar components:NSDayCalendarUnit fromDate:filterFrom toDate:filterTo options:0] day] + 1;
  
  // Get the number of days in a week
  NSDateComponents *oneWeek = [[NSDateComponents alloc] init];
  [oneWeek setWeek:1];
  NSDate *nextWeek = [calendar dateByAddingComponents:oneWeek toDate:fromDate options:0];
  NSUInteger daysInWeek = [[calendar components:NSDayCalendarUnit fromDate:fromDate toDate:nextWeek options:0] day];
  NSUInteger daysInMonth = [calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:fromDate].length;
  
  // Tell the graph view controller to cleanup
  // TODO: this is here since Core-Plot v0.2.2 has a retain cycle with plots and their datasources.  This can hopefully be removed in a future version...
  if (graphViewController)
    [graphViewController cleanup];
  
  if (days == 1)
    graphViewController = [[DayGraphViewController alloc] initWithFromDate:filterFrom toDate:filterTo];
  else if (days == daysInWeek)
    graphViewController = [[WeekGraphViewController alloc] initWithFromDate:filterFrom toDate:filterTo];
  else if (days == daysInMonth)
    graphViewController = [[MonthGraphViewController alloc] initWithFromDate:filterFrom toDate:filterTo];
    
  // Add the new graph view as a subview of graphView
  NSView *newGraphView = [graphViewController view];
  [newGraphView setFrame:[graphView bounds]];
  [graphView addSubview:newGraphView];
}

@end
