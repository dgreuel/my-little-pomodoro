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

#import "MLPAppDelegate.h"
#import "MainWindowController.h"
#import "DockTileView.h"
#import "TimerController.h"
#import "ModelController.h"
#import "KWPreferencesWindowController.h"
#import "StatsWindowController.h"

#define kWebsiteURL @"http://www.voltagesoft.com/my-little-pomodoro"
#define kSupportURL @"http://www.voltagesoft.com/my-little-pomodoro/support"

@interface MLPAppDelegate (Private)

- (void)addStatusBarItem;
- (void)removeStatusBarItem;

@end

@implementation MLPAppDelegate

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{
  if ([keyPath isEqual:@"values.ShowStatusBarItem"])
  {
    // Add the status bar item to the status bar if this was toggled on, or remove it if this was toggled off
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowStatusBarItem"])
      [self addStatusBarItem];
    else
      [self removeStatusBarItem];
  }
    
  if ([keyPath isEqual:@"timeRemaining"])
  {
    NSString *timeRemaining = [change objectForKey:NSKeyValueChangeNewKey];
    NSString *badgeLabel = ([[NSUserDefaults standardUserDefaults] boolForKey:@"BadgeDockIcon"]) ? timeRemaining : nil;
    NSString *statusBarItemTitle = ([[NSUserDefaults standardUserDefaults] boolForKey:@"ShowStatusBarItem"] && [[NSUserDefaults standardUserDefaults] boolForKey:@"ShowTimerInStatusBar"]) ? timeRemaining : nil;
    
    // If the timer is not running, don't display the time remaining
    if (![[TimerController sharedInstance] timerIsRunning])
    {
      badgeLabel = nil;
      statusBarItemTitle = nil;
    }
    
    // Update dockTileView's label and redraw the dock tile
    [dockTileView setLabel:badgeLabel];
    [[NSApp dockTile] display];
    
    // Update the status bar item's title
    [statusBarItem setTitle:statusBarItemTitle];
  }
}

- (NSManagedObjectContext *)managedObjectContext 
{
  return [[ModelController sharedInstance] managedObjectContext];
}

#pragma mark -
#pragma mark Menu Item methods

- (BOOL)validateMenuItem:(NSMenuItem *)item 
{
  // TODO:  this is a hack, and the code below is repeated elsewhere, in more appropriate places.  If the user accesses the status bar menu then cancel the attention request and set the badge label to nil (removes the !).
  [NSApp cancelUserAttentionRequest:NSCriticalRequest];
  [[NSApp dockTile] setBadgeLabel:nil];
  
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

- (void)showPreferences:(id)sender
{
  // If the app is not active, make it so
  if (![NSApp isActive])
    [NSApp activateIgnoringOtherApps:YES];
  
  if (!preferencesWindowController)
    preferencesWindowController = [[KWPreferencesWindowController alloc] init];
  
  [preferencesWindowController showWindow:sender];
}

- (void)openWebsite:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kWebsiteURL]];
}

- (void)openSupport:(id)sender
{
  [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kSupportURL]];
}

/**
 * Shows the stats window
 */
- (IBAction)showStatsWindow:(id)sender
{
  // If the app is not active, make it so
  if (![NSApp isActive])
    [NSApp activateIgnoringOtherApps:YES];
  
  if (!statsWindowController)
    statsWindowController = [[StatsWindowController alloc] init];
  
  [statsWindowController showWindow:sender];
}

/**
 * Shows the general stats section of the stats window
 */
- (IBAction)showGeneralStats:(id)sender
{
  [self showStatsWindow:sender];
  [statsWindowController showGeneralStats];
}

/**
 * Shows the task log section of the stats window
 */
- (IBAction)showTaskLog:(id)sender
{
  [self showStatsWindow:sender];
  [statsWindowController showTaskLog];
}

/**
 * Shows the work unit log section of the stats window
 */
- (IBAction)showWorkUnitLog:(id)sender
{
  [self showStatsWindow:sender];
  [statsWindowController showWorkUnitLog];
}

/**
 * Called from the status bar menu.  Tells the main window controller to start the timer.
 */
- (void)startTimer:(id)sender
{
  [mainWindowController startTimer:sender];
}

/**
 * Called from the status bar menu.  Tells the main window controller to stop the timer.
 */
- (void)stopTimer:(id)sender
{
  [mainWindowController stopTimer:sender];
}

/**
 * Called from the status bar menu.  Tells the main window controller to reset the timer.
 */
- (void)resetTimer:(id)sender
{
  [mainWindowController resetTimer:sender];
}

/**
 * Called from the status bar menu.  Tells the main window controller to change the timer type to pomodoro.
 */
- (void)changeTimerTypeToPomodoro:(id)sender
{
  [mainWindowController changeTimerTypeToPomodoro:sender];
}

/**
 * Called from the status bar menu.  Tells the main window controller to change the timer type to short break.
 */
- (void)changeTimerTypeToShortBreak:(id)sender
{
  [mainWindowController changeTimerTypeToShortBreak:sender];
}

/**
 * Called from the status bar menu.  Tells the main window controller to change the timer type to long break.
 */
- (void)changeTimerTypeToLongBreak:(id)sender
{
  [mainWindowController changeTimerTypeToLongBreak:sender];
}

#pragma mark -
#pragma mark NSApplicationDelegate methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification 
{
  // Register the default settings in case this is application's first run
  NSString *defaultsPath = [[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
  NSDictionary *defaults = [NSDictionary dictionaryWithContentsOfFile:defaultsPath];
  [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
  
  // Create the dock tile view
  NSDockTile *dockTile = [NSApp dockTile];
  dockTileView = [[DockTileView alloc] initWithFrame:[[dockTile contentView] frame]];
  [dockTile setContentView:dockTileView];

  // Register as an observer for when the TimerController's "timeRemaining" key's value changes so we can update the dock tile view
  [[TimerController sharedInstance] addObserver:self forKeyPath:@"timeRemaining" options:NSKeyValueObservingOptionNew context:NULL];
  
  // Register as an observer for when the UserDefaultsController's "ShowStatusBarItem" key's value changes so we can display or hide the status bar item
  [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:@"values.ShowStatusBarItem" options:0 context:NULL];
  
  // Create the main window controller and show its window
  mainWindowController = [[MainWindowController alloc] init];
  [mainWindowController showWindow:self];
  
  // Add the status bar item if applicable
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  if ([userDefaults boolForKey:@"ShowStatusBarItem"])
    [self addStatusBarItem];
  
  // Set up a Pomodoro with autostart off so that it's ready for use
  NSString *autostartKey = @"Autostart";
  BOOL autostartUserDefault = [userDefaults boolForKey:autostartKey];
  [userDefaults setBool:NO forKey:autostartKey];
  [[TimerController sharedInstance] doPomodoro];
  [userDefaults setBool:autostartUserDefault forKey:autostartKey];
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification
{
  // Disable the badge label if one is set
  [[NSApp dockTile] setBadgeLabel:nil];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
  // Show the main window if it's not visible
  if (![[mainWindowController window] isVisible])
    [mainWindowController showWindow:self];
    
  return NO;
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
  // Save the data in the managed object context to the persistent store
  [[ModelController sharedInstance] save];
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
  return dockMenu;
}

#pragma mark -
#pragma mark Private methods

/**
 * Creates a status bar item for the app and adds it to the system's status bar
 */
- (void)addStatusBarItem
{
  NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
  
  statusBarItem = [statusBar statusItemWithLength:NSVariableStatusItemLength];
  [statusBarItem setImage:[NSImage imageNamed:@"StatusBarIcon"]];
  [statusBarItem setAlternateImage:[NSImage imageNamed:@"StatusBarIconAlternate"]];
  [statusBarItem setHighlightMode:YES];
  [statusBarItem setMenu:statusBarMenu];
}

/**
 * Removes the app's status bar item from the system's status bar
 */
- (void)removeStatusBarItem
{
  [[NSStatusBar systemStatusBar] removeStatusItem:statusBarItem];
}

@end
