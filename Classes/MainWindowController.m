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

#import "MainWindowController.h"
#import "TimerViewController.h"
#import "TasksViewController.h"
#import "TimerController.h"

#define kStartButtonIdentifier @"Start"
#define kStopButtonIdentifier @"Stop"
#define kResetButtonIdentifier @"Reset"

#define kAddSegmentIndex 0
#define kRemoveSegementIndex 1

#define kPomodoroSegmentIndex 0
#define kShortBreakSegmentIndex 1
#define kLongBreakSegmentIndex 2

#define kTimerMenuItemTag 1
#define kStartMenuItemTag 0
#define kStopMenuItemTag 1

@interface MainWindowController (Private)

- (void)timerStarted:(NSNotification *)notification;
- (void)timerStopped:(NSNotification *)notification;
- (void)timerFinished:(NSNotification *)notification;
- (void)timerReset:(NSNotification *)notification;

- (void)updateToolbarControls:(NSNotification *)notification;
- (void)updateBottomBarControls:(NSNotification *)notification;
- (void)updateMenuKeyEquivalents:(NSNotification *)notification;

- (void)taskSelectionChanged:(NSNotification *)notification;

- (NSInteger)indexForToolbarItemWithIdentifier:(NSString *)identifier;
- (NSToolbarItem *)toolbarItemWithIdentifier:(NSString *)identifier;

@end

@implementation MainWindowController

- (id)init
{
  if (self = [super initWithWindowNibName:@"MainWindow"]) 
  {
    // Do not cascade windows so that the correct frame for the main window can be saved
    [self setShouldCascadeWindows:NO];

    // Register as an observer for TimerStarted, TimerStopped, TimerFinished notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerStarted:) name:@"TimerStarted" object:[TimerController sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerStopped:) name:@"TimerStopped" object:[TimerController sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerFinished:) name:@"TimerFinished" object:[TimerController sharedInstance]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timerReset:) name:@"TimerReset" object:[TimerController sharedInstance]];
    
    // Register as an observer for TaskWasSelected, NoTaskWasSelected notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskSelectionChanged:) name:@"TaskWasSelected" object:tasksViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskSelectionChanged:) name:@"NoTaskWasSelected" object:tasksViewController];    
  }
  
  return self;
}

- (void)awakeFromNib
{
  // Initialize the timer view controller
  timerViewController = [[TimerViewController alloc] init];
  
  // Set the proper frame for the timer view controller's view,
  // set the proper autoresizing mask,
  // and add the view to the timerView "placeholder" view
  [[timerViewController view] setFrame:[timerView bounds]];
  [[timerViewController view] setAutoresizingMask:NSViewWidthSizable];
  [timerView addSubview:[timerViewController view]];
  
  // Patch the timer view controller into the responder chain
  NSResponder *theNextResponder = [self nextResponder];
	[self setNextResponder:timerViewController];
	[timerViewController setNextResponder:theNextResponder];
  
  // Initialize the tasks view controller
  tasksViewController = [[TasksViewController alloc] init];
  
  // Set the proper frame for the tasks view controller's view,
  // set the proper autoresizing mask,
  // and add the view to the tasksView "placeholder" view
  [[tasksViewController view] setFrame:[tasksView bounds]];
  [[tasksViewController view] setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
  [tasksView addSubview:[tasksViewController view]];
  
  // Patch the tasks view controller into the responder chain
	theNextResponder = [self nextResponder];
	[self setNextResponder:tasksViewController];
	[tasksViewController setNextResponder:theNextResponder];
}

/**
 * Validates all of the menu items this controller is responsible for:
 * Start, Stop, Reset, Type: Pomodoro, Type: Short Break, Type: Long Break
 */
- (BOOL)validateMenuItem:(NSMenuItem *)item 
{
  SEL theAction = [item action];
  BOOL timerIsRunning = [[TimerController sharedInstance] timerIsRunning];
  
  if (theAction == @selector(startTimer:))
    return !timerIsRunning;
  
  if (theAction == @selector(stopTimer:))
    return timerIsRunning;
  
  if (theAction == @selector(resetTimer:))
    return !timerIsRunning;
  
  if (theAction == @selector(changeTimerTypeToPomodoro:))
    return !timerIsRunning;
  
  if (theAction == @selector(changeTimerTypeToShortBreak:))
    return !timerIsRunning;
  
  if (theAction == @selector(changeTimerTypeToLongBreak:))
    return !timerIsRunning;
  
  return YES;
}

/**
 * Starts the timer
 */
- (IBAction)startTimer:(id)sender
{  
  [[TimerController sharedInstance] startTimer];
}

/**
 * Stops the timer
 */
- (IBAction)stopTimer:(id)sender
{  
  [[TimerController sharedInstance] stopTimer];
}

/**
 * Resets the timer
 */
- (IBAction)resetTimer:(id)sender
{  
  [[TimerController sharedInstance] resetTimer];
}

/**
 * Called when either button in the add/remove segmented control is pressed.  Tells the TasksViewController to add or remove a task.
 */
- (IBAction)addRemoveTask:(id)sender
{  
  if ([sender selectedSegment] == kAddSegmentIndex)
    [tasksViewController addTask:sender];
  else
    [tasksViewController removeTask:sender];
}

/**
 * Called when any button in the timer type segmented control is pressed.
 */
- (IBAction)changeTimerType:(id)sender
{
  NSInteger segment = [sender selectedSegment];
  
  if (segment == kPomodoroSegmentIndex)
    [self changeTimerTypeToPomodoro:sender];
  else if (segment == kShortBreakSegmentIndex)
    [self changeTimerTypeToShortBreak:sender];
  else if (segment == kLongBreakSegmentIndex)
    [self changeTimerTypeToLongBreak:sender];
}

/**
 * Changes the timer type to a Pomodoro
 */
- (void)changeTimerTypeToPomodoro:(id)sender
{
  [timerTypeSegmentedControl setSelectedSegment:kPomodoroSegmentIndex];
  [[TimerController sharedInstance] doPomodoro];
}

/**
 * Changes the timer type to a short break
 */
- (void)changeTimerTypeToShortBreak:(id)sender
{
  [timerTypeSegmentedControl setSelectedSegment:kShortBreakSegmentIndex];
  [[TimerController sharedInstance] doShortBreak];
}

/**
 * Changes the timer type to a long break
 */
- (void)changeTimerTypeToLongBreak:(id)sender
{
  [timerTypeSegmentedControl setSelectedSegment:kLongBreakSegmentIndex];
  [[TimerController sharedInstance] doLongBreak];
}

/**
 * Returns the frame for the current window after adding height to it
 */
- (NSRect)windowFrameByAddingHeight:(CGFloat)height
{
  NSRect windowFrame = [[self window] frame];
  
  // Add the height to the current frame and move the origin down to keep the window at the same origin
  windowFrame.size.height += height;
  windowFrame.origin.y -= height;
  
  // Amount of the origin beyond the visible frame
  CGFloat originVisibleFrameDelta = [[[self window] screen] visibleFrame].origin.y - windowFrame.origin.y;
  
  // Is the origin outside of the visible frame?  If so, fix that by moving the origin back into the visible frame
  if (originVisibleFrameDelta > 0)
    windowFrame.origin.y += originVisibleFrameDelta;

  return windowFrame;
}

#pragma mark -
#pragma mark NSWindowDelegate methods

- (NSRect)windowWillUseStandardFrame:(NSWindow *)window defaultFrame:(NSRect)newFrame
{
  // Ask TasksViewController for its full height (height without vertical scrollbars)
  CGFloat tasksViewFullHeight = [tasksViewController fullHeight];
  
  // Compare the full height to tasksView's height
  CGFloat heightDelta = tasksViewFullHeight - [tasksView frame].size.height;
  
  // Return the frame rect by adding the height difference
  return [self windowFrameByAddingHeight:heightDelta];
}

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)sender 
{
  return [[[NSApp delegate] managedObjectContext] undoManager];
}

#pragma mark -
#pragma mark Private methods

/**
 * Called after receiving the TimerStarted notification.
 */
- (void)timerStarted:(NSNotification *)notification
{
  [self updateToolbarControls:notification];
  [self updateBottomBarControls:notification];
  [self updateMenuKeyEquivalents:notification];
}

/**
 * Called after receiving the TimerStopped notification.
 */
- (void)timerStopped:(NSNotification *)notification
{
  [self updateToolbarControls:notification];
  [self updateBottomBarControls:notification];
  [self updateMenuKeyEquivalents:notification];
}

/**
 * Called after receiving the TimerFinished notification.
 */
- (void)timerFinished:(NSNotification *)notification
{
  [self updateToolbarControls:notification];
  [self updateBottomBarControls:notification];
  [self updateMenuKeyEquivalents:notification];
}

/**
 * Called after receiving the TimerReset notification.
 */
- (void)timerReset:(NSNotification *)notification
{
  [self updateBottomBarControls:notification];
}

/**
 * Updates the toolbar controls
 */ 
- (void)updateToolbarControls:(NSNotification *)notification
{
  NSString *identifierToRemove;
  NSString *identifierToAdd;
  BOOL otherControlsEnabled;
  
  NSString *name = [notification name];  
  if ([name isEqual:@"TimerStarted"])
  {
    identifierToRemove = kStartButtonIdentifier;
    identifierToAdd = kStopButtonIdentifier;
    otherControlsEnabled = NO;
  }
  else if ([name isEqual:@"TimerStopped"] || [name isEqual:@"TimerFinished"])
  {
    identifierToRemove = kStopButtonIdentifier;
    identifierToAdd = kStartButtonIdentifier;
    otherControlsEnabled = YES;
  }
  
  // Toggle the start/stop buttons
  NSToolbar *toolbar = [self.window toolbar];
  NSInteger index = [self indexForToolbarItemWithIdentifier:identifierToRemove];
  
  [toolbar removeItemAtIndex:index];
  [toolbar insertItemWithItemIdentifier:identifierToAdd atIndex:index];
  
  // Disable the reset toolbar item
  [[self toolbarItemWithIdentifier:kResetButtonIdentifier] setEnabled:otherControlsEnabled];
  
  // Disable the timer type segmented control
  [timerTypeSegmentedControl setEnabled:otherControlsEnabled];
}

/**
 * Updates the bottom bar controls
 */
- (void)updateBottomBarControls:(NSNotification *)notification
{
  BOOL timerStarted = [[notification name] isEqualToString:@"TimerStarted"];
  
  // Disable the add/remove segmented control if the timer has started, otherwise enable it (when the notification's name is TimerFinished or TimerReset)
  [addRemoveTaskSegmentedControl setEnabled:!timerStarted];
}

/**
 * Toggles the start/stop menu item key equivalent.
 */
- (void)updateMenuKeyEquivalents:(NSNotification *)notification
{
  NSMenu *timerMenu = [[[NSApp mainMenu] itemWithTag:kTimerMenuItemTag] submenu];
  NSMenuItem *stopMenuItem = [timerMenu itemWithTag:kStopMenuItemTag];
  NSMenuItem *startMenuItem = [timerMenu itemWithTag:kStartMenuItemTag];
  
  if ([[notification name] isEqualToString:@"TimerStarted"])
  {
    [startMenuItem setKeyEquivalent:@""];
    [stopMenuItem setKeyEquivalent:@"s"];
    [stopMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
  }
  else
  {
    [stopMenuItem setKeyEquivalent:@""];
    [startMenuItem setKeyEquivalent:@"s"];
    [startMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
  }
}

- (void)taskSelectionChanged:(NSNotification *)notification
{
  BOOL removeButtonEnabled = [[notification name] isEqualToString:@"TaskWasSelected"];
  
  [addRemoveTaskSegmentedControl setEnabled:removeButtonEnabled forSegment:kRemoveSegementIndex];
}

/**
 * Returns the index of the toolbar item with the given identifier
 */
- (NSInteger)indexForToolbarItemWithIdentifier:(NSString *)identifier
{
  NSInteger index = 0;
  
  for (NSToolbarItem *item in [[self.window toolbar] visibleItems])
  {
    if ([[item itemIdentifier] isEqual:identifier]) return index;
    
    index++;
  }
  
  return -1;
}

/**
 * Returns the toolbar item with the given identifier
 */
- (NSToolbarItem *)toolbarItemWithIdentifier:(NSString *)identifier
{
  for (NSToolbarItem *item in [[self.window toolbar] visibleItems])
    if ([[item itemIdentifier] isEqual:identifier]) return item;
  
  return nil;
}

@end