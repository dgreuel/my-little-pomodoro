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

#import "TimeUnitGraph.h"

@implementation TimeUnitGraph

@synthesize graph;

- (id)initWithFromDate:(NSDate *)from toDate:(NSDate *)to maximumYValue:(NSInteger)maxY
{
  if (self = [super init])
  {
    fromDate = from;
    toDate = to;
    maximumY = maxY;
    plotDataDict = [NSMutableDictionary dictionary];
    
    [self setupGraph];
    [self setupPlotSpace];
    [self setupAxes];
  }
  
  return self;
}

/**
 * Sets up the graph
 */
- (void)setupGraph
{
  // Create a graph with a theme
  graph = [(CPXYGraph *)[CPXYGraph alloc] initWithFrame:CGRectZero];
  [graph applyTheme:[CPTheme themeNamed:kCPSlateTheme]];
    
  // Set paddings
  CGFloat graphPadding = 10.0f;
  [graph setPaddingTop:graphPadding];
  [graph setPaddingRight:graphPadding];
  [graph setPaddingBottom:2 * graphPadding];
  [graph setPaddingLeft:graphPadding];
  
  // TODO:  This causes the axes to redisplay in a wacky way.  Find out why, and fix it in Core-Plot!
  CGFloat plotAreaFramePadding = 10.0f;
  [[graph plotAreaFrame] setPaddingTop:plotAreaFramePadding];
  [[graph plotAreaFrame] setPaddingRight:plotAreaFramePadding];
  [[graph plotAreaFrame] setPaddingBottom:plotAreaFramePadding];
  [[graph plotAreaFrame] setPaddingLeft:plotAreaFramePadding];
  
  // Set the corner radius
  [[graph plotAreaFrame] setCornerRadius:2.5f];
}

- (void)setupPlotSpace
{
  // Default implementation does nothing.
}

/**
 * Sets up the axes
 */
- (void)setupAxes
{
  // Set the text style for the axes labels
  CPTextStyle *textStyle = [CPTextStyle textStyle];
  [textStyle setFontSize:11.0f];
  
  CPXYAxisSet *axisSet = (CPXYAxisSet *)[graph axisSet];
  [[axisSet xAxis] setLabelTextStyle:textStyle];
  [[axisSet yAxis] setLabelTextStyle:textStyle];
  
  [[axisSet yAxis] setTitle:@"Completed Work Units"];
  [[axisSet yAxis] setTitleTextStyle:textStyle];
    
  // Set the gridlines
  CPLineStyle *gridLineStyle = [CPLineStyle lineStyle];
  [gridLineStyle setLineWidth:1.0f];
  [gridLineStyle setLineColor:[[CPColor blackColor] colorWithAlphaComponent:0.1f]];
  [[axisSet xAxis] setMajorGridLineStyle:gridLineStyle];
  [[axisSet yAxis] setMajorGridLineStyle:gridLineStyle];
}

/**
 * Creates a scatter plot and adds it to the graph.
 */
- (void)addScatterPlotWithData:(NSArray *)data identifier:(NSString *)identifier color:(CPColor *)color
{
  [plotDataDict setObject:data forKey:identifier];
  
	CPScatterPlot *plot = [[CPScatterPlot alloc] init];
  [plot setIdentifier:identifier];
  [plot setDataSource:self];
  [[plot dataLineStyle] setLineWidth:2.0f];
  [[plot dataLineStyle] setLineColor:color];
  [[plot dataLineStyle] setLineJoin:kCGLineJoinRound];
  
  CPColor *areaFillColor = [color colorWithAlphaComponent:0.15f];
  [plot setAreaFill:[CPFill fillWithColor:areaFillColor]];
  [plot setAreaBaseValue:[[NSDecimalNumber zero] decimalValue]];
        
  [graph addPlot:plot];
}

/**
 * Creates a bar plot and adds it to the graph.
 */
- (void)addBarPlotWithData:(NSArray *)data identifier:(NSString *)identifier color:(CPColor *)color
{
  CPBarPlot *plot = [CPBarPlot tubularBarPlotWithColor:[color colorWithAlphaComponent:0.2f] horizontalBars:NO];
  [plot setIdentifier:identifier];
  [plot setDataSource:self];

  [graph addPlot:plot];
}


#pragma mark -
#pragma mark CPDataSource methods

- (NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot
{
  return [[plotDataDict objectForKey:[plot identifier]] count];
}

- (NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
  NSArray *plotData = [plotDataDict objectForKey:[plot identifier]];
  NSDictionary *rowDict = [plotData objectAtIndex:index];
  
  if (fieldEnum == CPScatterPlotFieldX || fieldEnum == CPBarPlotFieldBarLocation)
  {
    NSDate *date = [rowDict objectForKey:kXValueKey];
    NSTimeInterval timeIntervalDiff = [date timeIntervalSinceDate:fromDate];
    return [NSNumber numberWithDouble:timeIntervalDiff];
  }
  else
    return [rowDict objectForKey:kYValueKey];
}

@end
