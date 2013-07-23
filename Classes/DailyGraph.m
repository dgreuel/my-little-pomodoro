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

#import "DailyGraph.h"

#define kDayTimeInterval 86400    // number of seconds in a day

@implementation DailyGraph

- (void)setupGraph
{
  [super setupGraph];
  
  // Set the plot area frame's padding so we can see the axis labels
  [[graph plotAreaFrame] setPaddingBottom:52.5f];
  [[graph plotAreaFrame] setPaddingLeft:50.0f];
}

- (void)setupPlotSpace
{
  // How many days are between fromDate and toDate?
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSInteger days = [[calendar components:NSDayCalendarUnit fromDate:fromDate toDate:toDate options:0] day] + 1;

  CPXYPlotSpace *plotSpace = (CPXYPlotSpace *)[graph defaultPlotSpace];
  [plotSpace setXRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromInt(0) length:CPDecimalFromInt(kDayTimeInterval * (days - 1))]];
  [plotSpace setYRange:[CPPlotRange plotRangeWithLocation:CPDecimalFromFloat(0) length:CPDecimalFromInteger(MAX(8, maximumY + 1))]];
}

- (void)setupAxes
{
  [super setupAxes];
  
  CPXYAxisSet *axisSet = (CPXYAxisSet *)[graph axisSet];
  
  CPXYAxis *xAxis = [axisSet xAxis];
  [xAxis setMajorIntervalLength:CPDecimalFromInt(kDayTimeInterval)];
  [xAxis setMinorTicksPerInterval:0];
  
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateStyle:NSDateFormatterShortStyle];
  CPTimeFormatter *timeFormatter = [[CPTimeFormatter alloc] initWithDateFormatter:dateFormatter];
  [timeFormatter setReferenceDate:fromDate];
  [xAxis setLabelFormatter:timeFormatter];
  [xAxis setLabelRotation:M_PI/2];
  
  NSArray *xAxisExclusionRanges = [NSArray arrayWithObject:[CPPlotRange plotRangeWithLocation:CPDecimalFromInt(-kDayTimeInterval) length:CPDecimalFromInt(-CGFLOAT_MAX)]];
  [xAxis setLabelExclusionRanges:xAxisExclusionRanges];
  
  CPXYAxis *yAxis = [axisSet yAxis];
  [yAxis setMajorIntervalLength:CPDecimalFromInt(1)];
  [yAxis setMinorTicksPerInterval:0];
  
  NSArray *yAxisExclusionRanges = [NSArray arrayWithObject:[CPPlotRange plotRangeWithLocation:CPDecimalFromInt(0) length:CPDecimalFromInt(-CGFLOAT_MAX)]];
  [yAxis setLabelExclusionRanges:yAxisExclusionRanges];
}

@end
