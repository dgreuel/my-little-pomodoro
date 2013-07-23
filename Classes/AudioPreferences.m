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

#import "AudioPreferences.h"
#import "TimerController.h"

#define kAudioPrefIdentifier @"Audio"

@interface AudioPreferences (Private)

- (void)stopSpeaking;
- (void)stopTickingSound;

@end

@implementation AudioPreferences

- (id)init
{
  if (self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil])
  {
    [self setTitle:[self identifier]];
  }
  
  return self;
}

/**
 * Return the sounds in the /System/Library/Sounds directory
 */
- (NSArray *)alarmSounds
{
  NSMutableArray *sounds = [NSMutableArray array];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSArray *directories = [fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSSystemDomainMask];
  
  if ([directories count] == 1)
  {
    NSString *soundsPath = [[[directories objectAtIndex:0] URLByAppendingPathComponent:@"Sounds"] path];
    
    // Does the specified directory exist?  If it does, add each playable sounds to the sounds array
    NSArray *directoryContents;
    if ((directoryContents = [fileManager contentsOfDirectoryAtPath:soundsPath error:NULL]))
    {
      for (NSString *sound in directoryContents)
      {
        sound = [sound stringByDeletingPathExtension];
        
        if ([NSSound soundNamed:sound])
          [sounds addObject:sound];
      }
    }
  }
  
  return sounds;
}

/**
 * Plays the newly selected alarm sound
 */
- (IBAction)alarmSoundChanged:(id)sender
{
  NSSound *alarmSound;
  if ((alarmSound = [NSSound soundNamed:[[NSUserDefaults standardUserDefaults] stringForKey:@"AlarmSound"]]))
    [alarmSound play]; 
}

/**
 * Returns a list of the system voice names
 */
- (NSArray *)alarmVoices
{
  NSMutableArray *voices = [NSMutableArray array];
  
  for (NSString *voice in [NSSpeechSynthesizer availableVoices])
  {
    NSString *voiceName = [[NSSpeechSynthesizer attributesForVoice:voice] objectForKey:NSVoiceName];
    [voices addObject:voiceName];
  }
  
  return voices;
}

/**
 * Called when the ticking sound enabled checkbox is changed
 */
- (IBAction)alarmVoiceEnabledChanged:(id)sender
{
  // Stop playing the demo speech if it is unchecked
  if ([sender state] == NSOffState)
    [self stopSpeaking];
}

/**
 * Speaks some demo text with the new alarm voice
 */
- (IBAction)alarmVoiceChanged:(id)sender
{ 
  // Stop the speech synth from speaking if it currently is
  [self stopSpeaking];
  
  NSString *voice = [[NSSpeechSynthesizer availableVoices] objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"AlarmVoiceIndex"]];
  
  speechSynth = [[NSSpeechSynthesizer alloc] initWithVoice:voice];
  
  NSString *demoText = [[NSSpeechSynthesizer attributesForVoice:voice] objectForKey:NSVoiceDemoText];
  [speechSynth startSpeakingString:demoText];
}

/**
 * Returns a list of available ticking sounds, as listed in TickingSounds.plist
 */
- (NSArray *)tickingSounds
{
  NSMutableArray *tickingSounds = [NSMutableArray array];
  
  NSString *tickingSoundsPlistPath = [[NSBundle mainBundle] pathForResource:@"TickingSounds" ofType:@"plist"];
  
  for (NSDictionary *tickingSoundDict in [NSArray arrayWithContentsOfFile:tickingSoundsPlistPath])
    [tickingSounds addObject:[tickingSoundDict valueForKey:@"Name"]];
     
  return tickingSounds;
}

/**
 * Called when the ticking sound enabled checkbox is changed
 */
- (IBAction)tickingSoundEnabledChanged:(id)sender
{
  // Stop playing the demo sound if it is unchecked
  if ([sender state] == NSOffState) 
    [self stopTickingSound];
}

/**
 * Sets the tick and tock filenames in the user defaults, and demos the selected ticking sound
 */
- (IBAction)tickingSoundChanged:(id)sender
{
  // Stop the ticking demo sound if it's playing
  [self stopTickingSound];
  
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  
  // Get the array of ticking sounds, and get the selected one
  NSString *tickingSoundsPlistPath = [[NSBundle mainBundle] pathForResource:@"TickingSounds" ofType:@"plist"];
  NSDictionary *tickingSoundDict = [[NSArray arrayWithContentsOfFile:tickingSoundsPlistPath] objectAtIndex:[userDefaults integerForKey:@"TickingSoundIndex"]];

  // Set the tick and tock filenames in the user defaults (so that the TimerController has easy access to them)
  [userDefaults setObject:[tickingSoundDict objectForKey:@"TickFilename"] forKey:@"TickingSoundTickFilename"];
  [userDefaults setObject:[tickingSoundDict objectForKey:@"TockFilename"] forKey:@"TickingSoundTockFilename"];
  
  // If the timer isn't running, demo the sounds
  if (![[TimerController sharedInstance] timerIsRunning])
  {    
    tickingSound = [NSSound soundNamed:[tickingSoundDict objectForKey:@"DemoFilename"]];
    [tickingSound setVolume:[userDefaults doubleForKey:@"TickingSoundVolume"]];
    [tickingSound play];
  }
}

#pragma mark -
#pragma mark KWPreferencePanel protocol methods

- (NSString *)identifier
{
  return kAudioPrefIdentifier;
}

- (NSImage *)image
{  
  return [NSImage imageNamed:NSStringFromClass([self class])];
}

- (void)close
{
  // Stop the speech synth from speaking
  [self stopSpeaking];
  
  // Stop the ticking demo sound if it's playing
  [self stopTickingSound];
}

#pragma mark -
#pragma mark Private methods

/**
 * Stop the speech synth from speaking.
 */
- (void)stopSpeaking
{
  // If the speech synth is not null and it is speaking, stop it
  if (speechSynth && [speechSynth isSpeaking]) [speechSynth stopSpeaking];
}

/**
 * Stop the ticking sound from playing.
 */
- (void)stopTickingSound
{
  // If the ticking demo sound is not null and it is playing, stop it
  if (tickingSound && [tickingSound isPlaying]) [tickingSound stop];
}

@end