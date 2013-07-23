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

#import "GrowlController.h"
#import "SynthesizeSingleton.h"

@implementation GrowlController

SYNTHESIZE_SINGLETON_FOR_CLASS(GrowlController);

- (id)init
{
  if (self = [super init])
  {
    // Set self as the GAB's delegate
    [GrowlApplicationBridge setGrowlDelegate:self];
  }
  
  return self;
}

- (void)notifyGrowlPomodoroCompleted
{
  [GrowlApplicationBridge notifyWithTitle:[self applicationNameForGrowl] description:@"Pomodoro finished." notificationName:@"Timer Finished" iconData:nil priority:0 isSticky:NO clickContext:@"timerFinishedContext"];
}

- (void)notifyGrowlShortBreakCompleted
{
  [GrowlApplicationBridge notifyWithTitle:[self applicationNameForGrowl] description:@"Short break finished." notificationName:@"Timer Finished" iconData:nil priority:0 isSticky:NO clickContext:@"timerFinishedContext"];
}

- (void)notifyGrowlLongBreakCompleted
{
  [GrowlApplicationBridge notifyWithTitle:[self applicationNameForGrowl] description:@"Long break finished." notificationName:@"Timer Finished" iconData:nil priority:0 isSticky:NO clickContext:@"timerFinishedContext"];
}

#pragma mark -
#pragma mark GrowlApplicationBridgeDelegate methods

- (NSDictionary *)registrationDictionaryForGrowl
{
  NSArray *notifications = [NSArray arrayWithObjects:@"Timer Finished", nil];
  
  return [NSDictionary dictionaryWithObjectsAndKeys:notifications, GROWL_NOTIFICATIONS_ALL, notifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
}

- (NSString *)applicationNameForGrowl
{
  // Never change this, not even for a "lite" or "trial" version
  return @"My Little Pomodoro";
}

- (void)growlNotificationWasClicked:(id)clickContext
{
  // Make the application active and tell it that it should reopen
  [NSApp activateIgnoringOtherApps:YES];
  [[NSApp delegate] applicationShouldHandleReopen:NSApp hasVisibleWindows:NO];
}

@end
