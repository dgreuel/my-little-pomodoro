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

#import "MessengersController.h"
#import "MessengerController.h"
#import "SynthesizeSingleton.h"

#define kiChatAvailableScriptFilename @"iChatSetStatusAvailable"
#define kiChatAwayScriptFilename @"iChatSetStatusAwayWithMessage"
#define kAdiumAvailableScriptFilename @"AdiumSetStatusAvailable"
#define kAdiumAwayScriptFilename @"AdiumSetStatusAwayWithMessage"
#define kSkypeAvailableScriptFilename @"SkypeSetStatusAvailable"
#define kSkypeAwayScriptFilename @"SkypeSetStatusAwayWithMessage"

@interface MessengersController (Private)

- (BOOL)iChatStatusControlEnabled;
- (BOOL)adiumStatusControlEnabled;
- (BOOL)skypeStatusControlEnabled;

@end


@implementation MessengersController

SYNTHESIZE_SINGLETON_FOR_CLASS(MessengerController);

- (id)init
{
  if (self = [super init])
  {
    currentStatus = StatusAvailable;
    
    iChatController = [[MessengerController alloc] initWithAvailableScriptFilename:kiChatAvailableScriptFilename awayScriptFilename:kiChatAwayScriptFilename];
    adiumController = [[MessengerController alloc] initWithAvailableScriptFilename:kAdiumAvailableScriptFilename awayScriptFilename:kAdiumAwayScriptFilename];
    skypeController = [[MessengerController alloc] initWithAvailableScriptFilename:kSkypeAvailableScriptFilename awayScriptFilename:kSkypeAwayScriptFilename];
  }
  
  return self;
}

- (void)setStatusAvailable
{
  // If we're not away, don't try to set the status to available
  if (currentStatus != StatusAway) return;
  
  currentStatus = StatusAvailable;
  
  if ([self iChatStatusControlEnabled])
    [iChatController setStatusAvailable];
  
  if ([self adiumStatusControlEnabled])
    [adiumController setStatusAvailable];
  
  if ([self skypeStatusControlEnabled])
    [skypeController setStatusAvailable];
}

- (void)setStatusAway
{
  if (currentStatus != StatusAvailable) return;
  
  currentStatus = StatusAway;
  
  NSString *statusMessage = [[NSUserDefaults standardUserDefaults] stringForKey:@"PomodoroStatusMessage"];
  
  if ([self iChatStatusControlEnabled])
    [iChatController setStatusAwayWithMessage:statusMessage];
  
  if ([self adiumStatusControlEnabled])
    [adiumController setStatusAwayWithMessage:statusMessage];
  
  if ([self skypeStatusControlEnabled])
    [skypeController setStatusAwayWithMessage:statusMessage];
}


#pragma mark -
#pragma mark Private methods

- (BOOL)iChatStatusControlEnabled
{
  return [[NSUserDefaults standardUserDefaults] boolForKey:@"iChatStatusControlEnabled"];
}

- (BOOL)adiumStatusControlEnabled
{
  return [[NSUserDefaults standardUserDefaults] boolForKey:@"AdiumStatusControlEnabled"];
}

- (BOOL)skypeStatusControlEnabled
{
  return [[NSUserDefaults standardUserDefaults] boolForKey:@"SkypeStatusControlEnabled"];
}

@end
