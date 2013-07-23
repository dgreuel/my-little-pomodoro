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

#import "TaskLogViewController.h"
#import "ModelController.h"

@implementation TaskLogViewController

- (id)init
{
  if (self = [super initWithNibName:@"TaskLogView" bundle:nil]) {
  }
  
  return self;
}

- (void)awakeFromNib 
{
  // Sort the table view by creationDate in ascending order
  NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
  [tasksTableView setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

///**
// * Validates all menu items that have this object as their target
// */
//- (BOOL)validateMenuItem:(NSMenuItem *)item 
//{
//  SEL theAction = [item action];
//    
//  // Delete should be enabled only if there is a clicked row or there is a selected row
//  if (theAction == @selector(removeTasksPermanently:))
//    return [tasksTableView clickedRow] != -1 || [tasksTableView selectedRow] != -1;
//  
//  return YES;
//}
//
///**
// * Action for the "Delete" menu item
// */
//- (IBAction)removeTasksPermanently:(id)sender
//{
//  // Save the clicked row index before displaying the alert, since clicking a button in the alert changes table view's clickedRow to -1!
//  NSInteger clickedRow = [tasksTableView clickedRow];
//  
//  // Display the permanent task removal alert if it's not suppressed
//  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//  if (![userDefaults boolForKey:@"PermanentTaskRemovalAlertSuppressed"])
//  {
//    // Ask the user if they want to permanently remove these tasks
//    NSAlert *permanentAlert = [[NSAlert alloc] init];
//    [permanentAlert addButtonWithTitle:@"Remove"];
//    [permanentAlert addButtonWithTitle:@"Cancel"];
//    [permanentAlert setMessageText:@"Are you sure you want to remove the selected tasks?"];
//    [permanentAlert setInformativeText:@"The selected tasks will be permanently removed and cannot be restored."];
//    [permanentAlert setAlertStyle:NSWarningAlertStyle];
//    [permanentAlert setShowsSuppressionButton:YES];
//    [[permanentAlert suppressionButton] setTitle:@"Do not ask me again"];
//    
//    NSInteger clickedAlertButton = [permanentAlert runModal];
//    
//    // Update the user defaults if the user wants to suppress this alert
//    if ([[permanentAlert suppressionButton] state] == NSOnState)
//      [userDefaults setBool:YES forKey:@"PermanentTaskRemovalAlertSuppressed"];
//    
//    // Don't remove any tasks if the user clicked the cancel button
//    if (clickedAlertButton == NSAlertSecondButtonReturn) return;
//  }
//  
//  // Remove all of the selected tasks
//  NSMutableIndexSet *rowIndexesToRemove = [[NSMutableIndexSet alloc] initWithIndexSet:[tasksTableView selectedRowIndexes]];
//    
//  // Remove the clicked row if there is one
//  if (clickedRow != -1)
//    [rowIndexesToRemove addIndex:clickedRow];
//  
//  // Check if the user is trying to remove the current task
//  Task *currentTask = [[ModelController sharedInstance] currentTask];
//  NSUInteger currentTaskIndex = [[tasksArrayController arrangedObjects] indexOfObject:currentTask];
//  if (currentTaskIndex != NSNotFound)
//  {
//    // Disallow removal of the current task
//    [rowIndexesToRemove removeIndex:currentTaskIndex];
//    
//    // Tell the user that they're not allowed to remove the current task
//    NSAlert *currentTaskAlert = [[NSAlert alloc] init];
//    [currentTaskAlert addButtonWithTitle:@"OK"];
//    [currentTaskAlert setMessageText:[NSString stringWithFormat:@"The task \"%@\" could not be removed.", [currentTask name]]];
//    [currentTaskAlert setInformativeText:@"You attempted to remove the current task.  Try removing this task when you are done working on it."];
//    [currentTaskAlert setAlertStyle:NSWarningAlertStyle];
//    [currentTaskAlert runModal];
//  }
//  
//  // Remove 'em!
//  [tasksArrayController removeObjectsAtArrangedObjectIndexes:rowIndexesToRemove];
//}


#pragma mark -
#pragma mark StatsViewController methods

- (void)filterContentFrom:(NSDate *)fromDate to:(NSDate *)toDate
{
  [tasksArrayController setFilterPredicate:[Task creationDatePredicateFrom:fromDate to:toDate]];
}

@end
