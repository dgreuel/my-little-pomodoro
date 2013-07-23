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

#import "DayGraphViewController.h"
#import "HourlyGraph.h"
#import "ModelClasses.h"

#define kPomodoroPlot @"PomodoroPlot"
#define kShortBreakPlot @"ShortBreakPlot"
#define kLongBreakPlot @"LongBreakPlot"

@implementation DayGraphViewController

- (id)initWithFromDate:(NSDate *)from toDate:(NSDate *)to
{
  if (self = [super initWithFromDate:from toDate:to])
  {
    // Get the tabular data dicts for the date range
    NSDictionary *pomodoroDataDict = [Pomodoro tabularHourlyCompletedFrom:from to:to calendar:[NSCalendar currentCalendar]];
    NSDictionary *shortBreakDataDict = [ShortBreak tabularHourlyCompletedFrom:from to:to calendar:[NSCalendar currentCalendar]];
    NSDictionary *longBreakDataDict = [LongBreak tabularHourlyCompletedFrom:from to:to calendar:[NSCalendar currentCalendar]];
    
    NSArray *pomodoroData = [pomodoroDataDict objectForKey:kDataKey];
    NSArray *shortBreakData = [shortBreakDataDict objectForKey:kDataKey];
    NSArray *longBreakData = [longBreakDataDict objectForKey:kDataKey];
    
    // Get the max Y values
    NSInteger pomodoroMaxY = [[pomodoroDataDict objectForKey:kMaxYKey] integerValue];
    NSInteger shortBreakMaxY = [[shortBreakDataDict objectForKey:kMaxYKey] integerValue];
    NSInteger longBreakMaxY = [[longBreakDataDict objectForKey:kMaxYKey] integerValue];
    NSInteger maxY = MAX(pomodoroMaxY, MAX(shortBreakMaxY, longBreakMaxY));
    
    // Create the graph
    timeUnitGraph = [[HourlyGraph alloc] initWithFromDate:from toDate:to maximumYValue:maxY];
    
    // Set up the plots
    [timeUnitGraph addScatterPlotWithData:longBreakData identifier:kLongBreakPlot color:[CPColor greenColor]];
    [timeUnitGraph addScatterPlotWithData:shortBreakData identifier:kShortBreakPlot color:[CPColor yellowColor]];
    [timeUnitGraph addScatterPlotWithData:pomodoroData identifier:kPomodoroPlot color:[CPColor redColor]];
    
    // Show the graph
    [hostView setHostedLayer:[timeUnitGraph graph]];
  }
  
  return self;
}

@end
