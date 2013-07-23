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

#import "ModelController.h"
#import "SynthesizeSingleton.h"

#define kApplicationSupportName @"My Little Pomodoro"
#define kPersistentStoreFilename @"MyLittlePomodoro.db"

@interface ModelController (Private)

- (void)managedObjectContextObjectsDidChange:(NSNotification *)notification;
- (NSString *)applicationSupportPath;

@end

@implementation ModelController

@synthesize currentTask, currentWorkUnit;
SYNTHESIZE_SINGLETON_FOR_CLASS(ModelController);

- (id)init
{
  if (self = [super init])
  {
    // Observe changes to objects in the managed object context
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:[self managedObjectContext]];
  }
  
  return self;
}

/**
 * Starts a Pomodoro work unit with the specified length
 */
- (Pomodoro *)startPomodoroWithLength:(NSTimeInterval)theLength
{
  // Do not create another Pomodoro if there is a current work unit
  if (currentWorkUnit) return (Pomodoro *)currentWorkUnit;
  
  // Disable undo registration
  [self disableUndoRegistration];
  
  // Create a new Pomodoro and set some properties
  Pomodoro *pomodoro = [Pomodoro insertInManagedObjectContext:[self managedObjectContext]];
  [pomodoro setTask:currentTask];
  [pomodoro setBeginDate:[NSDate date]];
  [pomodoro setLength:[NSNumber numberWithDouble:theLength]];
  
  // Re-enable undo registration
  [self enableUndoRegistration];
  
  // Set this new work unit to be the current one
  currentWorkUnit = pomodoro;
  
  return pomodoro;
}

/**
 * Starts a ShortBreak work unit with the specified length
 */
- (ShortBreak *)startShortBreakWithLength:(NSTimeInterval)theLength
{
  if (currentWorkUnit) return (ShortBreak *)currentWorkUnit;
  
  // Disable undo registration
  [self disableUndoRegistration];
  
  ShortBreak *shortBreak = [ShortBreak insertInManagedObjectContext:[self managedObjectContext]];
  [shortBreak setTask:currentTask];
  [shortBreak setBeginDate:[NSDate date]];
  [shortBreak setLength:[NSNumber numberWithDouble:theLength]];
  
  // Re-enable undo registration
  [self enableUndoRegistration];
  
  currentWorkUnit = shortBreak;
  
  return shortBreak;
}

/**
 * Starts a LongBreak work unit with the specified length
 */
- (LongBreak *)startLongBreakWithLength:(NSTimeInterval)theLength
{
  if (currentWorkUnit) return (LongBreak *)currentWorkUnit;
  
  // Disable undo registration
  [self disableUndoRegistration];
  
  LongBreak *longBreak = [LongBreak insertInManagedObjectContext:[self managedObjectContext]];
  [longBreak setTask:currentTask];
  [longBreak setBeginDate:[NSDate date]];
  [longBreak setLength:[NSNumber numberWithDouble:theLength]];
  
  // Re-enable undo registration
  [self enableUndoRegistration];
  
  currentWorkUnit = longBreak;
  
  return longBreak;
}

- (void)incrementStopsForCurrentWorkUnit
{
  if (!currentWorkUnit) return;
  
  // Disable undo registration
  [self disableUndoRegistration]; 
  
  short stops = [[currentWorkUnit stops] shortValue] + 1;
  [currentWorkUnit setStops:[NSNumber numberWithShort:stops]];

  // Re-enable undo registration
  [self enableUndoRegistration];
}

/**
 * Finishes the current work unit by setting the end date if it's completed and setting currentWorkUnit to nil
 */
- (void)finishCurrentWorkUnit:(BOOL)completed
{
  // Disable undo registration
  [self disableUndoRegistration]; 
  
  // If the work unit completed and there is a currentWorkUnit, then set the end date
  if (completed && currentWorkUnit)
    [currentWorkUnit setEndDate:[NSDate date]];
  
  // Re-enable undo registration
  [self enableUndoRegistration];
  
  // Force the managed object context to process the pending changes (i.e., the setting of the current work unit's end date)
  [[self managedObjectContext] processPendingChanges];
  
  // Set the currentWorkUnit to nil so that we can create a new one on the next start
  currentWorkUnit = nil;
}

/**
 * Disable undo registration
 */
- (void)disableUndoRegistration
{
  [[[self managedObjectContext] undoManager] disableUndoRegistration];
}

/**
 * Processes pending changes in the MOC and re-enables undo registration
 */
- (void)enableUndoRegistration
{
  [[self managedObjectContext] processPendingChanges];
  [[[self managedObjectContext] undoManager] enableUndoRegistration];
}

/**
 * Returns the number of objects with the given entity description and the given predicate
 */
- (NSNumber *)numberOfObjectsWithEntityDescription:(NSEntityDescription *)entity predicate:(NSPredicate *)predicate
{  
  NSManagedObjectContext *moc = [[ModelController sharedInstance] managedObjectContext];
  
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  [request setEntity:entity];
  [request setPredicate:predicate];
  
  NSError *error = nil;
  NSUInteger numberOfObjects = [moc countForFetchRequest:request error:&error];
  
  NSUInteger result = (!error) ? numberOfObjects : 0;
  
  return [NSNumber numberWithUnsignedInteger:result];
}

/**
 * Called when an object in the managed object context changes.
 * Currently it looks at the updated objects and refreshes the object's task
 */
- (void)managedObjectContextObjectsDidChange:(NSNotification *)notification
{
  // Get the updated objects
  NSSet *updatedObjects = [[notification userInfo] objectForKey:NSUpdatedObjectsKey];
  
  for (id changedObject in updatedObjects)
  {
    // Is the updated object's class a subclass of the WorkUnit class?
    if (![[changedObject class] isSubclassOfClass:NSClassFromString(@"WorkUnit")]) 
      continue;
    
    // Get the object's task, and if it exists, refresh the task object
    Task *task = [changedObject task];
    if (task) [[self managedObjectContext] refreshObject:task mergeChanges:YES];
  }
}


#pragma mark -
#pragma mark Core Data stack setup methods

- (NSManagedObjectModel *)managedObjectModel 
{
  if (managedObjectModel) return managedObjectModel;
  
  managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
  
  return managedObjectModel;
}

- (NSManagedObjectContext *)managedObjectContext 
{
  if (managedObjectContext) return managedObjectContext;
  
  NSString *applicationSupportPath = [self applicationSupportPath];
  
  // Check if the application's support directory exists, and create it if it doesn't
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath:applicationSupportPath])
    [fileManager createDirectoryAtPath:applicationSupportPath withIntermediateDirectories:YES attributes:nil error:nil];
  
  // Create the persistent store coordinator
  NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
  
  // Create a persistent store
  NSError *error = nil;
  NSURL *url = [NSURL fileURLWithPath:[applicationSupportPath stringByAppendingPathComponent:kPersistentStoreFilename]];
  
  // Allow lightweight migration
  NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
  
  NSPersistentStore *persistentStore = [coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:options error:&error];
  if (persistentStore)
  {
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:coordinator];
  } 
  else
    [NSApp presentError:error];
  
  return managedObjectContext;
}

- (void)save
{
  NSError *error = nil;
  
  if (![[self managedObjectContext] save:&error])
    [NSApp presentError:error];
}

#pragma mark -
#pragma mark Private methods

- (NSString *)applicationSupportPath 
{  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
  NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
  return [basePath stringByAppendingPathComponent:kApplicationSupportName];
}

@end
