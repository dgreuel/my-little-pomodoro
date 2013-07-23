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

#import "Timer.h"

#define kReadyState @"ready"
#define kRunningState @"running"
#define kStoppedState @"stopped"
#define kDoneState @"done"

@interface Timer (Private)

- (void)tick:(NSTimer *)theTimer;

@end

@implementation Timer

@synthesize delegate;
@synthesize duration, timeLeft;

- (id)init
{
  return [self initWithDuration:0];
}

- (id)initWithDuration:(NSTimeInterval)seconds
{
  // All durations must be non-negative
  if (seconds < 0)
  {
    [self release];
    return nil;
  }
  
  self = [super init];
  if (self)
  {
    duration = seconds;
    timeLeft = duration;
    
    // Set the state to ready
    state = kReadyState;
  }
  
  return self;
}

/**
 * Tries to start the timer and returns if it was successful
 */
- (BOOL)start
{ 
  if (state == kReadyState || state == kStoppedState)
  {   
    // Set the end date in the user info dictionary
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSDate dateWithTimeIntervalSinceNow:timeLeft] forKey:@"endDate"];
    
    // Create a timer that fires every second
    timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(tick:) userInfo:userInfo repeats:YES];
    
    // Add the timer to the common mode run loops
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    
    // Set the state to running and fire an event now
    state = kRunningState;
    [timer fire];
    
    return YES;
  }
  
  return NO;
}

/**
 * Tries to stop the timer and returns if it was successful
 */
- (BOOL)stop
{ 
  if (state == kRunningState)
  {
    // Invalidate the timer (since we can only come from the running state, we know the timer is valid)
    [timer invalidate];
    
    state = kStoppedState;
    
    return YES;
  }
  
  return NO;
}

/**
 * Resets the timer to the current duration and returns if it was successful
 */
- (BOOL)reset
{
  return [self resetWithDuration:duration];
}

/**
 * Resets the timer to the specified number of seconds and returns if it was successful
 */
- (BOOL)resetWithDuration:(NSTimeInterval)seconds
{
  if (state == kDoneState || state == kStoppedState || state == kReadyState)
  {
    state = kReadyState;
    
    // Update the timer's duration
    duration = seconds;
    
    // Reset the amount of time left
    timeLeft = duration;
    
    return YES;
  }
  
  return NO;
}

/**
 * Updates the timer and tells delegate that the timer ticked and possibly finished
 */
- (void)tick:(NSTimer *)theTimer
{   
  if (state == kRunningState)
  {
    NSDate *endDate = [[theTimer userInfo] objectForKey:@"endDate"];
    timeLeft = [endDate timeIntervalSinceNow];
    
    // Is there any time left on the clock?
    if (timeLeft > 0)
    {
      // Tell the delegate the the timer has ticked
      if ([delegate respondsToSelector:@selector(timerTicked:)])
        [delegate timerTicked:self];
    }
    else
    {
      // Reset timeLeft so that it's non-negative
      timeLeft = 0;
      
      // Invalidate the timer
      [timer invalidate];
      
      state = kDoneState;
      
      if ([delegate respondsToSelector:@selector(timerFinished:)])
        [delegate timerFinished:self];
    }
  }
}

/**
 * Returns the amount of time remaining on the timer in M:SS or MM:SS format
 */
- (NSString *)timeRemaining
{
  NSDate *date1 = [NSDate date];
  NSDate *date2 = [NSDate dateWithTimeInterval:round(timeLeft) sinceDate:date1];
 
  NSUInteger unitFlags = NSMinuteCalendarUnit | NSSecondCalendarUnit;  
  NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:date1 toDate:date2 options:0];
  
  // TODO: add formatting for years, months, days, hours, minutes, seconds?
  return [NSString stringWithFormat:@"%d:%02d", [components minute], [components second]];
}

/**
 * Returns if the timer is in the ready state
 */ 
- (BOOL)isReady
{
  return state == kReadyState;
}

/**
 * Returns if the timer is in the running state
 */ 
- (BOOL)isRunning
{
  return state == kRunningState;
}


/**
 * Returns if the timer is in the stopped state
 */ 
- (BOOL)isStopped
{
  return state == kStoppedState;
}

/**
 * Returns if the timer is in the done state
 */ 
- (BOOL)isDone
{
  return state == kDoneState;
}

@end