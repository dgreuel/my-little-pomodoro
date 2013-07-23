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

#import "TasksViewController.h"
#import "ModelController.h"
#import "MainWindowController.h"
#import "TimerController.h"

#define kTaskDescriptionColumnIdentifier @"TaskDescriptionColumn"
#define kWantedTasksViewHeight 200.0

@interface TasksViewController (Private)

- (BOOL)shouldChangeTaskSelection;
- (void)updateViews:(NSNotification *)notification;

@end

@implementation TasksViewController

- (id)init
{
  if (self = [super initWithNibName:@"TasksView" bundle:nil]) 
  {
    // Register as an observer for TimerStarted, TimerReset, and TimerFinished notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViews:) name:@"TimerStarted" object:[TimerController sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViews:) name:@"TimerStopped" object:[TimerController sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViews:) name:@"TimerReset" object:[TimerController sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViews:) name:@"TimerFinished" object:[TimerController sharedInstance]];
    
    // Should we alert the user regarding changes to the current task selection when the timer is stopped?
    shouldAlertForTaskChange = YES;
  }
  
  return self;
}

- (void)awakeFromNib 
{
  // Filter out tasks where isVisible = NO
  [tasksArrayController setFilterPredicate:[Task visiblePredicate:YES]];
  
  // Sort the table view by creation date in ascending order
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
  [tasksTableView setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (BOOL)validateMenuItem:(NSMenuItem *)item 
{
  SEL theAction = [item action];
  
  if (theAction == @selector(addTask:))
    return [tasksTableView isEnabled];
      
  if (theAction == @selector(removeTask:))
    return [tasksTableView isEnabled] && ([tasksArrayController selectionIndex] != NSNotFound);
  
  if (theAction == @selector(removeCompletedTasks:))
    return [tasksTableView isEnabled];
    
  return YES;
}

/**
 * Adds a task to the tasks array controller and resizes the window to show the tasks list if necessary
 */ 
- (void)addTask:(id)sender
{
  // Prompt the user if they're sure they want to end the current work unit and add a new task, and don't ask them again till the timer has been started again
  if ([self shouldChangeTaskSelection])
    shouldAlertForTaskChange = NO;
  else
    return;
  
  [tasksArrayController addObject:[tasksArrayController newObject]];
  
  CGFloat tasksViewHeight = [[self view] frame].size.height;
  CGFloat wantedHeightDelta = kWantedTasksViewHeight - tasksViewHeight;

  // If there is a positive difference in wanted vs. actual heights (that is, the actual height is less than the wanted height), then resize the window to the wanted height
  if (wantedHeightDelta > 0)
  {
    // Disable the vertical scroller so that resizing the table view looks smoother
    NSScrollView *enclosingScrollView = [tasksTableView enclosingScrollView];
    BOOL hasVerticalScroller = [enclosingScrollView hasVerticalScroller];
    [enclosingScrollView setHasVerticalScroller:NO];
    
    // Resize the window
    NSWindow *mainWindow = [[self view] window];
    MainWindowController *mainWindowController = (MainWindowController *)[[[self view] window] windowController];
    [mainWindow setFrame:[mainWindowController windowFrameByAddingHeight:wantedHeightDelta] display:YES animate:YES];
    
    // Re-enable the vertical scroller
    [enclosingScrollView setHasVerticalScroller:hasVerticalScroller];
  }

  // Scroll to the selected row and begin editing the task field
  [tasksTableView editColumn:[tasksTableView columnWithIdentifier:kTaskDescriptionColumnIdentifier] row:[tasksTableView selectedRow] withEvent:nil select:YES];
}

/**
 * Removes a task by setting the task's isVisible attribute to NO
 */
- (void)removeTask:(id)sender
{
  // Prompt the user if they're sure they want to end the current work unit and remove the selected task, and don't ask them again till the timer has been started again
  if ([self shouldChangeTaskSelection])
    shouldAlertForTaskChange = NO;
  else
    return;
  
  // For safety, return if there are no selected objects
  if ([[tasksArrayController selectedObjects] count] == 0) return;
  
  // Get the currently selected task
  Task *taskToRemove = [[tasksArrayController selectedObjects] objectAtIndex:0];
  
  // Select the next or previous task
  if ([tasksArrayController canSelectNext])
    [tasksArrayController setSelectionIndex:[tasksArrayController selectionIndex] + 1];
  else if ([tasksArrayController canSelectPrevious])
    [tasksArrayController setSelectionIndex:[tasksArrayController selectionIndex] - 1];
  
  // Set the task's |isVisible| property to NO 
  [taskToRemove setIsVisibleValue:NO];  
}

/**
 * Removes all completed tasks by setting each task's isVisible attribute to NO
 */
- (void)removeCompletedTasks:(id)sender
{
  // Prompt the user if they're sure they want to end the current work unit and remove the completed tasks, and don't ask them again till the timer has been started again
  if ([self shouldChangeTaskSelection])
    shouldAlertForTaskChange = NO;
  else
    return;  
  
  for (Task *task in [tasksArrayController content])
  {
    if ([task isCompletedValue])
      [task setIsVisibleValue:NO];
  }
}

/**
 * Returns the height of the tasks table view so that there is no vertical scrolling necessary
 */
- (CGFloat)fullHeight
{
  CGFloat headerViewHeight = [[tasksTableView headerView] frame].size.height;
  
  NSScrollView *scrollView = [tasksTableView enclosingScrollView];
  CGFloat documentHeight = [[scrollView documentView] frame].size.height;
  
  CGFloat scrollViewDocumentWidth = [[scrollView documentView] frame].size.width;
  CGFloat scrollViewContentWidth = [scrollView contentSize].width;
  
  // If the scroll view's document view is wider than the content view, there is a horizontal scrollbar displayed
  CGFloat horizontalScrollerHeight = (scrollViewDocumentWidth > scrollViewContentWidth) ? [[scrollView horizontalScroller] frame].size.height : 0;
  
  // Full height = header view height + document height + horizontal scroller height
  return headerViewHeight + documentHeight + horizontalScrollerHeight;
}

#pragma mark -
#pragma mark NSTableViewDelegate methods

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
  static NSInteger previousSelectionIndex = -1;
  
  // If we're not selecting the previous index, and the task selection should change (if the timer is stopped and a new task is selected), then reset the current timer (which resets the current work unit and task)
  if (previousSelectionIndex != [tasksArrayController selectionIndex] && [self shouldChangeTaskSelection])
    [[TimerController sharedInstance] resetTimer];
  else
    [tasksArrayController setSelectionIndex:previousSelectionIndex];
  
  // Store the selection for use in the next task change
  previousSelectionIndex = [tasksArrayController selectionIndex];
  
  Task *currentTask = ([tasksArrayController selectionIndex] != NSNotFound) ? [[tasksArrayController selectedObjects] objectAtIndex:0] : nil;
  [[ModelController sharedInstance] setCurrentTask:currentTask];
 
  // Post a notification specifying wether a task was selected or not selected
  NSString *notificationName = (currentTask) ? @"TaskWasSelected" : @"NoTaskWasSelected";
  [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
}

#pragma mark -
#pragma mark Private methods

/**
 * Prompts the user and asks them if they want to end the current work unit early and switch tasks if the timer is stopped.
 */
- (BOOL)shouldChangeTaskSelection
{
  if (shouldAlertForTaskChange && [[TimerController sharedInstance] timerIsStopped])
  {
    NSAlert *changeAlert = [[NSAlert alloc] init];
    [changeAlert addButtonWithTitle:@"OK"];
    [changeAlert addButtonWithTitle:@"Cancel"];
    [changeAlert setMessageText:@"Are you sure you want to do that?"];
    [changeAlert setInformativeText:@"Changing tasks, adding a new task, or removing this task will end the current timer."];
    [changeAlert setShowsHelp:YES];
    [changeAlert setHelpAnchor:@"TaskChangeWhileTimerIsStopped"];
    
    return ([changeAlert runModal] == NSAlertFirstButtonReturn);
  }
  
  return YES;
}

- (void)updateViews:(NSNotification *)notification
{  
  BOOL timerStarted = [[notification name] isEqualToString:@"TimerStarted"];
  
  [tasksTableView setEnabled:!timerStarted];
  
  // Each time the timer starts again, we should always alert regarding task changes
  if (timerStarted)
    shouldAlertForTaskChange = YES;
}

@end
