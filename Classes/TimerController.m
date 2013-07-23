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

#import "TimerController.h"
#import "SynthesizeSingleton.h"
#import "ModelController.h"
#import "GrowlController.h"
#import "MessengersController.h"

#define kTimerPomodoro @"Pomodoro"
#define kTimerShortBreak @"ShortBreak"
#define kTimerLongBreak @"LongBreak"

@interface TimerController (Private)

- (void)changeType:(NSString *)theType;
- (void)updateTimeRemaining;
- (NSTimeInterval)lengthOfTimerWithType:(NSString *)timerType;

- (void)timerTicked:(Timer *)theTimer;
- (void)timerFinished:(Timer *)theTimer;

@end

@implementation TimerController

@synthesize timeRemaining;
SYNTHESIZE_SINGLETON_FOR_CLASS(TimerController);

- (id)init
{
  if (self = [super init])
  {
    timer = [[Timer alloc] init];
    timer.delegate = self;
  }
  
  return self;
}

#pragma mark -
#pragma mark Timer Control Methods

/**
 * Starts the timer, posts a notification that the timer started, and tells the model controller to create a work unit.
 */
- (void)startTimer
{
  // If the timer is in the ready or done state, reset the timer with the length of the selected timer type
  if ([timer isReady] || [timer isDone])
    [timer resetWithDuration:[self lengthOfTimerWithType:type]];
  
  // If the timer doesn't start, bust out of here!
  if (![timer start]) return;
  
  // Post a notification that the timer started
  [[NSNotificationCenter defaultCenter] postNotificationName:@"TimerStarted" object:self];
  
  // When the timer starts, create a WorkUnit object to represent the current work unit
  NSTimeInterval currentTimerLength = [timer duration];
  
  if ([type isEqualToString:kTimerPomodoro])
    [[ModelController sharedInstance] startPomodoroWithLength:currentTimerLength];
  else if ([type isEqualToString:kTimerShortBreak])
    [[ModelController sharedInstance] startShortBreakWithLength:currentTimerLength];
  else if ([type isEqualToString:kTimerLongBreak])
    [[ModelController sharedInstance] startLongBreakWithLength:currentTimerLength];
  
  // Set status messages to away in the enabled messengers
  if ([type isEqualToString:kTimerPomodoro])
    [[MessengersController sharedInstance] setStatusAway];
}

/**
 * Stops the timer and tells the model controller to increment the number of stops for the current work unit.
 */
- (void)stopTimer
{
  // If the timer doesn't stop...
  if (![timer stop]) return;
  
  // Post a notification that the timer stopped
  [[NSNotificationCenter defaultCenter] postNotificationName:@"TimerStopped" object:self];
  
  [[ModelController sharedInstance] incrementStopsForCurrentWorkUnit];
}

/**
 * Resets the timer, and tells the model controller that the current work unit is finished (albeit incomplete).
 */
- (void)resetTimer
{
  // If the timer doesn't reset...
  if (![timer resetWithDuration:[self lengthOfTimerWithType:type]]) return;
  
  // Post a notification that the timer reset
  [[NSNotificationCenter defaultCenter] postNotificationName:@"TimerReset" object:self];
  
  // Update the time remaining
  [self updateTimeRemaining];
  
  // Tell the model controller that the current work unit is finished, but it did not complete (since the timer was reset)
  [[ModelController sharedInstance] finishCurrentWorkUnit:NO];
  
  // Set status messages to available in the enabled messengers
  [[MessengersController sharedInstance] setStatusAvailable];
}

/**
 * Sets the timer to be a Pomodoro
 */
- (void)doPomodoro
{
  [self changeType:kTimerPomodoro];
}

/**
 * Sets the timer to be a short break
 */
- (void)doShortBreak
{
  [self changeType:kTimerShortBreak];
}

/**
 * Sets the timer to be a long break
 */
- (void)doLongBreak
{
  [self changeType:kTimerLongBreak];
}

/**
 * Returns true if the timer is running
 */
- (BOOL)timerIsRunning
{
  return [timer isRunning];
}

/**
 * Returns true if the timer is stopped
 */
- (BOOL)timerIsStopped
{
  return [timer isStopped];
}

#pragma mark -
#pragma mark Private methods

/**
 * Changes the timer type and resets the timer
 */
- (void)changeType:(NSString *)theType
{
  // TODO: Timer can only change type when it is not running, so add checking for this
  type = theType;
  [self resetTimer];
  
  // Start the timer if autostart is true
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Autostart"])
    [self startTimer];
}

/**
 * Updates the remaining time left on the timer.
 */
- (void)updateTimeRemaining
{
  [self setValue:[timer timeRemaining] forKey:@"timeRemaining"];
}

/**
 * Gets the length of the timer with the passed in type.
 */
- (NSTimeInterval)lengthOfTimerWithType:(NSString *)timerType
{
  return [[NSUserDefaults standardUserDefaults] doubleForKey:[timerType stringByAppendingString:@"Length"]] * 60;
}

#pragma mark TimerDelegate methods

- (void)timerTicked:(Timer *)theTimer
{
  // Update the remaining time
  [self updateTimeRemaining];
  
  // Tick when timeLeft is even, tock when timeLeft is odd
  BOOL isTick = (int)round([timer timeLeft]) % 2 == 0;
  
  // Play either the tick or tock sound if ticking is enabled
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  if ([userDefaults boolForKey:@"TickingSoundEnabled"])
  {
    // Don't play the ticking sound if the user doesn't want it to be played during breaks
    if (![userDefaults boolForKey:@"TickingSoundEnabledDuringBreaks"] && (type != kTimerPomodoro)) return;
    
    float tickingSoundVolume = [userDefaults floatForKey:@"TickingSoundVolume"];
    NSString *soundNameKey = (isTick) ? @"TickingSoundTickFilename" : @"TickingSoundTockFilename";
    
    NSSound *sound = [NSSound soundNamed:[userDefaults stringForKey:soundNameKey]];
    [sound setVolume:tickingSoundVolume];
    [sound play];
  }
}

- (void)timerFinished:(Timer *)theTimer
{
  // Update the remaining time
  [self updateTimeRemaining];
  
  // Post a notification that the timer finished
  [[NSNotificationCenter defaultCenter] postNotificationName:@"TimerFinished" object:self];
  
  // Tell the model controller that the current work unit ended and was completed 
  [[ModelController sharedInstance] finishCurrentWorkUnit:YES];
  
  // Set the app's badge label to indicate the timer finished if the app is not active
  if (![NSApp isActive])
    [[NSApp dockTile] setBadgeLabel:@"!"];

  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  
  // Bounce the app icon in the dock
  if ([userDefaults boolForKey:@"BounceDockIcon"])
    [NSApp requestUserAttention:NSCriticalRequest];
  
  // Display notifications with Growl if it's enabled
  if ([userDefaults boolForKey:@"NotifyUsingGrowl"])
  {
    if ([type isEqualToString:kTimerPomodoro])
      [[GrowlController sharedInstance] notifyGrowlPomodoroCompleted];
    else if ([type isEqualToString:kTimerShortBreak])
      [[GrowlController sharedInstance] notifyGrowlShortBreakCompleted];
    else if ([type isEqualToString:kTimerLongBreak])
      [[GrowlController sharedInstance] notifyGrowlLongBreakCompleted];
  }
  
  // Play the alarm sound if it's enabled
  if ([userDefaults boolForKey:@"AlarmSoundEnabled"])
  {
    NSSound *alarmSound;
    if ((alarmSound = [NSSound soundNamed:[userDefaults stringForKey:@"AlarmSound"]]))
      [alarmSound play];
  }
  
  // Speak in the alarm voice if it's enabled
  if ([userDefaults boolForKey:@"AlarmVoiceEnabled"])
  {
    NSString *voice = [[NSSpeechSynthesizer availableVoices] objectAtIndex:[userDefaults integerForKey:@"AlarmVoiceIndex"]];
    
    NSSpeechSynthesizer *speechSynth = [[NSSpeechSynthesizer alloc] initWithVoice:voice];
    [speechSynth startSpeakingString:[type stringByAppendingString:@" finished."]];
  }
  
  // Set status messages to available in the enabled messengers
  [[MessengersController sharedInstance] setStatusAvailable];
}

@end