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

#import "KWPreferencesWindowController.h"
#import "KWPreferencePanel.h"

#define kLastSelectedPanelIdentifier @"LastSelectedPanelIdentifier"

@interface KWPreferencesWindowController (Private)

- (void)selectPanel:(id)sender;
- (void)changeToPanel:(id <KWPreferencePanel>)panel;

@end

@implementation KWPreferencesWindowController

- (id)init
{
  if (self = [super init])
  {
    // Initialize instance variables
    preferencePanels = [NSMutableDictionary dictionary];
    preferencePanelIdentifiers = [NSMutableArray array];
    
    // Create a window and set its delegate
    NSWindow *preferencesWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 0, 0) styleMask:(NSTitledWindowMask | NSClosableWindowMask) backing:NSBackingStoreBuffered defer:YES];
    [preferencesWindow setShowsToolbarButton:NO];
    [preferencesWindow setDelegate:self];
    [self setWindow:preferencesWindow];
    
    // Load in the toolbar panels from the property-list
    NSString *plistPath;
    
    if ((plistPath = [[NSBundle mainBundle] pathForResource:@"PreferencePanels" ofType:@"plist"]))
    {
      NSArray *preferencePanelDicts = [[NSDictionary dictionaryWithContentsOfFile:plistPath] objectForKey:@"PreferencePanels"];

      // For each preference panel in the property-list, save its identifier in an array, create an instance of its class (and set its title), and save it in the panels dictionary
      for (NSDictionary *panelDict in preferencePanelDicts)
      {
        id <KWPreferencePanel> panel = [[NSClassFromString([panelDict objectForKey:@"Class"]) alloc] init];
        NSString *identifier = [panel identifier];
        
        [preferencePanels setObject:panel forKey:identifier];
        [preferencePanelIdentifiers addObject:identifier];
      }
    }
    else
      [NSException raise:NSGenericException format:@"Cannot find PreferencePanels.plist."];
    
    // Create a toolbar
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"PreferencesToolbar"];
    [toolbar setDelegate:self];
    [self.window setToolbar:toolbar];
    
    // Select either the last selected panel, or the first panel if there was no last selected panel (i.e., first run)
    if ([preferencePanels count])
    {
      id <KWPreferencePanel> lastSelectedPanel = nil;
      NSString *lastSelectedPanelIdentifier = [[NSUserDefaults standardUserDefaults] stringForKey:kLastSelectedPanelIdentifier];
      
      if (!(lastSelectedPanel = [preferencePanels objectForKey:lastSelectedPanelIdentifier]))
        lastSelectedPanel = [preferencePanels objectForKey:[preferencePanelIdentifiers objectAtIndex:0]];
      
      [self changeToPanel:lastSelectedPanel];
    }
  }
  
  // Center the preferences window
  [self.window center];
  
  return self;
}

- (void)selectPanel:(id)sender
{
  if (![sender isKindOfClass:[NSToolbarItem class]]) return;
  
  [self changeToPanel:[preferencePanels objectForKey:[(NSToolbarItem *)sender itemIdentifier]]];
}

- (void)changeToPanel:(id <KWPreferencePanel>)panel
{ 
  // Tell the current panel to close and then remove its view from the window
  [currentPanel close];
  [[currentPanel view] removeFromSuperview];
  
  NSView *panelView = [panel view];
  
  // Resize the window so that it fits the new panel's view
  NSRect windowFrame = [self.window frameRectForContentRect:[panelView frame]];
  windowFrame.origin = [self.window frame].origin;
  windowFrame.origin.y -= windowFrame.size.height - [self.window frame].size.height;
  [self.window setFrame:windowFrame display:YES animate:YES];  [self.window setFrame:windowFrame display:YES animate:YES]; 
  
  [[self.window toolbar] setSelectedItemIdentifier:[panel identifier]];
  [self.window setTitle:[panel title]];
  
  currentPanel = panel;
  [[self.window contentView] addSubview:[currentPanel view]];
  
  // Save the selection
  [[NSUserDefaults standardUserDefaults] setObject:[panel identifier] forKey:kLastSelectedPanelIdentifier];
}

#pragma mark -
#pragma mark NSWindowDelegate methods

- (void)windowWillClose:(NSNotification *)notification
{
  // Tell each of the preference panels that they will be closing
  [[preferencePanels allValues] makeObjectsPerformSelector:@selector(close)];
}

#pragma mark -
#pragma mark NSToolbarDelegate methods

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
  // Return all of the allowed toolbar item identifiers
  return preferencePanelIdentifiers;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
  // Return all of the toolbar item identifiers that are on the toolbar by default
  return preferencePanelIdentifiers;
}

- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
  // Returns all of the toolbar item identifiers since they're all selectable
  return preferencePanelIdentifiers;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
  id <KWPreferencePanel> panel = [preferencePanels objectForKey:itemIdentifier];
  
  NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
  [item setLabel:[panel title]];
  [item setImage:[panel image]];
  [item setTarget:self];
  [item setAction:@selector(selectPanel:)];
  
  return item;
}

@end
