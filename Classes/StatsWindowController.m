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

#import "StatsWindowController.h"
#import "KWMixedTrackingSegmentedCell.h"
#import "OutlineViewItem.h"
#import "GeneralStatsViewController.h"
#import "TaskLogViewController.h"
#import "WorkUnitLogViewController.h"

#define kStatisticsItemIdentifier @"StatsItemIdentifier"
#define kGeneralItemIdentifier @"GeneralItemIdentifier"
#define kLogsItemIdentifier @"LogsItemIdentifier"
#define kTasksItemIdentifier @"TasksItemIdentifier"
#define kWorkUnitsItemIdentifier @"WorkUnitsItemIdentifier"

#define kLeftSegmentIndex 0
#define kDaySegmentIndex 1
#define kWeekSegmentIndex 2
#define kMonthSegmentIndex 3
#define kRightSegmentIndex 4

@interface StatsWindowController (Private)

- (void)populateOutlineViewItems;
- (NSUInteger)indexForOutlineViewItemWithIdentifier:(NSString *)identifier;
- (void)changeToViewController:(id <StatsViewController>)viewController;
- (void)filterCurrentViewControllerContent;

- (void)selectRangeForDate:(NSDate *)date;

- (void)selectIndexForOutlineViewWithIdentifier:(NSString *)identifier;

@end


@implementation StatsWindowController

- (id)init
{
  if (self = [super initWithWindowNibName:@"StatsWindow"]) 
  {
    // Populate the outline view items array
    [self populateOutlineViewItems];
	}
  
	return self;
}

- (void)awakeFromNib
{
  // Tell the periodSegmentedControl's cell about the indexes we don't want to be able to select
  NSMutableIndexSet *disallowedIndexes = [NSMutableIndexSet indexSet];
  [disallowedIndexes addIndex:kLeftSegmentIndex];
  [disallowedIndexes addIndex:kRightSegmentIndex];
  [[periodSegmentedControl cell] setDisallowedSelectionIndexes:disallowedIndexes];
  
  // Expand all of the groups in the outline view
  [outlineView expandItem:nil expandChildren:YES];
  
  // Set up the date picker
  [datePicker setCalendar:[NSCalendar currentCalendar]];
  [self selectRangeForDate:[NSDate date]];
  
  // Select the general item in the outline view
  [self selectIndexForOutlineViewWithIdentifier:kGeneralItemIdentifier];
  
  // Filter the view controller's data
  [self filterCurrentViewControllerContent];
}

- (GeneralStatsViewController *)generalStatsViewController
{
  if (!generalStatsViewController)
    generalStatsViewController = [[GeneralStatsViewController alloc] init];
  
  return generalStatsViewController;
}

- (TaskLogViewController *)taskLogViewController
{
  if (!taskLogViewController)
    taskLogViewController = [[TaskLogViewController alloc] init];
  
  return taskLogViewController;
}

- (WorkUnitLogViewController *)workUnitLogViewController
{
  if (!workUnitLogViewController)
    workUnitLogViewController = [[WorkUnitLogViewController alloc] init];
  
  return workUnitLogViewController;
}

/**
 * Selects the Stats -> General outline view item
 */
- (void)showGeneralStats
{
  [self selectIndexForOutlineViewWithIdentifier:kGeneralItemIdentifier];
}

/**
 * Selects the Log -> Task outline view item
 */
- (void)showTaskLog
{
  [self selectIndexForOutlineViewWithIdentifier:kTasksItemIdentifier];
}

/**
 * Selects the Log -> Work Unit outline view item
 */
- (void)showWorkUnitLog
{
  [self selectIndexForOutlineViewWithIdentifier:kWorkUnitsItemIdentifier];
}

/**
 * Returns if the current view controller can filter its data by a date range
 */
- (BOOL)canCurrentViewControllerFilterByDate
{
  return [currentViewController respondsToSelector:@selector(filterContentFrom:to:)];
}

/**
 * Action for periodSegmentedControl
 */
- (IBAction)changeDateRange:(id)sender
{
  // If this isn't sent from the period segmented control, return
  if (![sender isEqual:periodSegmentedControl]) return;
  
  // Amount to advance calendar (can be negative)
  int amountToMove = 0;
  
  NSInteger lastClickedIndex = [[sender cell] lastClickedIndex];
  if (lastClickedIndex == kLeftSegmentIndex)
    amountToMove = -1;
  else if (lastClickedIndex == kRightSegmentIndex)
    amountToMove = 1;
  else
  {
    // Day, week, or month was pressed, so call the proper method to select the correct date range
    [self selectRangeForDate:[datePicker dateValue]];
    return;
  }
  
  // If we made it this far, the left or right segment button was pressed
  NSCalendar *calendar = [datePicker calendar];
  NSDateComponents *oneUnit = [[NSDateComponents alloc] init];
  
  // Set oneUnit based on the currently selected segment
  switch ([sender selectedSegment])
  {
    case kDaySegmentIndex:
      [oneUnit setDay:amountToMove];
      break;
    case kWeekSegmentIndex:
      [oneUnit setWeek:amountToMove];
      break;
    case kMonthSegmentIndex:
      [oneUnit setMonth:amountToMove];
      break;
    default:
      break;
  }
  
  // Set the new date
  NSDate *newDate = [calendar dateByAddingComponents:oneUnit toDate:[datePicker dateValue] options:0];
  [self selectRangeForDate:newDate];
}

/**
 * Action for the date picker
 */
- (IBAction)datePickerAction:(id)sender
{
  [self selectRangeForDate:[datePicker dateValue]];
}

/**
 * Action for the today button
 */
- (IBAction)todayButtonAction:(id)sender
{
  [self selectRangeForDate:[NSDate date]];
}


#pragma mark -
#pragma mark NSOutlineViewDataSource methods

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
  return (!item) ? [outlineViewItems objectAtIndex:index] : [[item children] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{ 
  // The item is expandable only if it has children
  return [item hasChildren];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
  return (!item) ? [outlineViewItems count] : [[item children] count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
  NSString *itemTitle = [item title];
  
  // Capitalize the titles of group items
  if ([item isGroupItem])
    itemTitle = [itemTitle uppercaseString];
  
  return itemTitle;
}


#pragma mark -
#pragma mark NSOutlineViewDelegate methods

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
  return [item isGroupItem];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
  // Group items should not be selectable
  return ![item isGroupItem];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{  
  NSString *itemIdentifier = [[outlineView itemAtRow:[outlineView selectedRow]] identifier];
  
  if ([itemIdentifier isEqualToString:kGeneralItemIdentifier])
    [self changeToViewController:[self generalStatsViewController]];
  else if ([itemIdentifier isEqualToString:kTasksItemIdentifier])
    [self changeToViewController:[self taskLogViewController]];
  else if ([itemIdentifier isEqualToString:kWorkUnitsItemIdentifier])
    [self changeToViewController:[self workUnitLogViewController]];
}


#pragma mark -
#pragma mark Private methods

/**
 * Fills the outline view items array
 */
- (void)populateOutlineViewItems
{
  OutlineViewItem *generalItem = [[OutlineViewItem alloc] initWithTitle:@"General" identifier:kGeneralItemIdentifier];
  
  // Statistics is a group with General, Averages, and Lifetime as children
  OutlineViewItem *statsItem = [[OutlineViewItem alloc] initWithTitle:@"Statistics" identifier:kStatisticsItemIdentifier];
  [statsItem setIsGroupItem:YES];
  [statsItem setChildren:[NSArray arrayWithObjects:generalItem, nil]];
  
  OutlineViewItem *tasksItem = [[OutlineViewItem alloc] initWithTitle:@"Tasks" identifier:kTasksItemIdentifier];
  OutlineViewItem *workUnitsItem = [[OutlineViewItem alloc] initWithTitle:@"Work Units" identifier:kWorkUnitsItemIdentifier];
  
  // Logs is a group with Tasks and Work Units as children
  OutlineViewItem *logsItem = [[OutlineViewItem alloc] initWithTitle:@"Logs" identifier:kLogsItemIdentifier];
  [logsItem setIsGroupItem:YES];
  [logsItem setChildren:[NSArray arrayWithObjects:tasksItem, workUnitsItem, nil]];
  
  // Set the ouline view items array
  outlineViewItems = [NSArray arrayWithObjects:statsItem, logsItem, nil];
}

/**
 * Returns the row index for the outline view item with identifier, or -1 if there is no item with the specified identifier
 */
- (NSUInteger)indexForOutlineViewItemWithIdentifier:(NSString *)identifier
{
  for (int i = 0; i < [outlineView numberOfRows]; i++)
  {
    if ([identifier isEqualToString:[[outlineView itemAtRow:i] identifier]])
      return i;
  }
  
  return -1;
}

/**
 * Changes the current view controller, and swaps out the old current view controller's view for the new view controller's view in mainView
 */
- (void)changeToViewController:(id <StatsViewController>)viewController
{  
  // Don't change views if the passed in view controller is already current
  if (currentViewController == viewController) return;
  
  // Remove the current view from its superview, only if the current view controller is not nil
  if (currentViewController)
    [[currentViewController view] removeFromSuperview];
  
  // Let any observers know that the following key will change
  [self willChangeValueForKey:@"canCurrentViewControllerFilterByDate"];
  
  // Set the new view controller, change the frame of the new vc's view to the bounds of mainView, and add the new view as a subview of mainView
  currentViewController = viewController;
  [[currentViewController view] setFrame:[mainView bounds]];
  [mainView addSubview:[currentViewController view]];
  
  // Let any observers know that the following key did change
  [self didChangeValueForKey:@"canCurrentViewControllerFilterByDate"];
  
  // Filter the current view controller's content
  [self filterCurrentViewControllerContent];
}

/**
 * Tells the current view controller to filter its content
 */
- (void)filterCurrentViewControllerContent
{
  if ([self canCurrentViewControllerFilterByDate])
  {
    NSDate *fromDate = [datePicker dateValue];
    NSDate *toDate = [fromDate dateByAddingTimeInterval:[datePicker timeInterval]];
    [currentViewController filterContentFrom:fromDate to:toDate];
  }
}

/**
 * Selects a date and time interval for the date picker, and tells the current view controller to filter
 */
- (void)selectRangeForDate:(NSDate *)date
{
  NSCalendarUnit unit;

  switch ([periodSegmentedControl selectedSegment]) 
  {
    case kDaySegmentIndex:
      unit = NSDayCalendarUnit;
      break;
    case kWeekSegmentIndex:
      unit = NSWeekCalendarUnit;
      break;
    case kMonthSegmentIndex:
      unit = NSMonthCalendarUnit;
      break;
    default:
      unit = NSDayCalendarUnit;
      break;
  }
  
  NSCalendar *calendar = [datePicker calendar];
  NSDate *beginDate = nil;
  NSTimeInterval timeInterval = 0;
  
  if ([calendar rangeOfUnit:unit startDate:&beginDate interval:&timeInterval forDate:date])
  {    
    [datePicker setDateValue:beginDate];
    [datePicker setTimeInterval:timeInterval - 1];
    
    [self filterCurrentViewControllerContent];
  }
}

/**
 * Selects an item in the outline view given |identifier|
 */
- (void)selectIndexForOutlineViewWithIdentifier:(NSString *)identifier
{
  NSUInteger indexToSelect = [self indexForOutlineViewItemWithIdentifier:identifier];
  if (indexToSelect != -1)
    [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:indexToSelect] byExtendingSelection:NO];  
}

@end