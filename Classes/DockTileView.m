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

#import "DockTileView.h"

#define kDockTileBadgeImage @"DockTileBadge.png"

@implementation DockTileView

@synthesize label;

- (id)initWithFrame:(NSRect)frame 
{  
  if (self = [super initWithFrame:frame]) 
  {
    // Create the attributes dictionary for the label, and set the font color
    labelAttributes = [NSMutableDictionary dictionary];
    [labelAttributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    // Set the label's shadow
    NSShadow *labelShadow = [[NSShadow alloc] init];
    [labelShadow setShadowOffset:NSMakeSize(2.0, -2.0)];
    [labelShadow setShadowBlurRadius:4.0];
    [labelAttributes setObject:labelShadow forKey:NSShadowAttributeName];
  }

  return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
  // Draw the application icon
  [[NSApp applicationIconImage] drawInRect:dirtyRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
  
  // If the label is not set, do not draw the badge and the label
  if (!label) return;
  
  // Draw the badge image
  NSImage *badge = [NSImage imageNamed:kDockTileBadgeImage];
  NSRect badgeRect = NSMakeRect(0.0, 0.0, badge.size.width, badge.size.height);
  [badge drawInRect:badgeRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];

  // Determine the largest font size below 25 pt that fits within the badge
  NSSize labelSize;
  CGFloat fontSize = 25.0;
  
  do 
  {
    [labelAttributes setObject:[NSFont boldSystemFontOfSize:fontSize] forKey:NSFontAttributeName];
    labelSize = [label sizeWithAttributes:labelAttributes];
    fontSize -= 1.0;
  } while (labelSize.width > NSWidth(badgeRect) || labelSize.height > NSHeight(badgeRect));
  
  NSRect labelRect;
  labelRect.origin.x = NSMidX(badgeRect) - labelSize.width / 2.0;
  labelRect.origin.y = NSMidY(badgeRect) - labelSize.height / 2.0 + 1.0;  // adjust for shadow amount
  labelRect.size = [label sizeWithAttributes:labelAttributes];
  
  // Draw the label
  [label drawInRect:labelRect withAttributes:labelAttributes];
}

@end
