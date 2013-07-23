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

#import "KWMixedTrackingSegmentedCell.h"

@interface KWMixedTrackingSegmentedCell (Private)

- (void)commonInit;

@end


@implementation KWMixedTrackingSegmentedCell

@synthesize lastClickedIndex;
@synthesize disallowedSelectionIndexes;

/**
 * Called by init and awakeFromNib, so that they share some common setup functionality
 */
- (void)commonInit
{
  [self setTrackingMode:NSSegmentSwitchTrackingSelectOne];
}

- (id)init
{
  if (self = [super init])
  {
    [self commonInit];
  }
  
  return self;
}

- (void)awakeFromNib
{
  [super awakeFromNib];
  
  [self commonInit];
}

- (void)setTrackingMode:(NSSegmentSwitchTracking)trackingMode
{
  // Force the tracking mode to be NSSegmentSwitchTrackingSelectOne
  [super setTrackingMode:NSSegmentSwitchTrackingSelectOne];
}

- (void)setSelectedSegment:(NSInteger)selectedSegment
{
  // Store the last clicked segment index
  lastClickedIndex = selectedSegment;
  
  // Disallow selection of the specified indexes
  if ([disallowedSelectionIndexes containsIndex:selectedSegment]) 
    return;
  
  [super setSelectedSegment:selectedSegment];
}

@end
