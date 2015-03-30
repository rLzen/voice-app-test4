//
//  AppDelegate.m
//  VoiceAppTest_v04
//
//  Created by Richard Lorenzen on 3/22/15.
//  Copyright (c) 2015 Richard Lorenzen. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "HomeVoxNotificationRegion.h"
#import "MasterViewController.h"

@interface AppDelegate ()

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *activeNotificationRegions;

-(BOOL)NSNumberEqual:(NSNumber*)number1 toNSNumber:(NSNumber*)number2;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Set up Core Location Manager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:
          UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    // Load any previously registered notifications
    [self loadNotificationRegions];
    
    [self.locationManager startUpdatingLocation];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    // If the application is in the foreground, we will notify the user of the region's state via an alert.
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:notification.alertBody message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)addNotificationRegion:(HomeVoxNotificationRegion *)newRegion
{
    // Keep track of the region in our array
    [_activeNotificationRegions addObject:newRegion];
    
    // Set up a region based on the parameters specified by the user
    CLBeaconRegion *region = [self buildBeaconRegionForNotificationRegion:newRegion];
    if(region)
    {
        // Notify on entry if the user specified a "hello" message
        region.notifyOnEntry = (newRegion.helloMessage != nil);
        
        // Notify on exit if the user specified a "goodbye" message
        region.notifyOnExit = (newRegion.goodbyeMessage != nil);
        
        // Register the region with core location
        [_locationManager startMonitoringForRegion:region];
    }
    
    // Save notification list to persistent storage
    [self saveNotificationRegions];
    
}

#pragma mark Notification region management

-(CLBeaconRegion*)buildBeaconRegionForNotificationRegion:(HomeVoxNotificationRegion *)newRegion
{
    // Register this region with Core Location so that we receive notifications
    CLBeaconRegion *region = nil;
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:newRegion.beaconUUID];
    
    if(uuid && newRegion.beaconMajor && newRegion.beaconMinor)
    {
        // Create a unique ID for this notification
        NSString* identifier = [NSString stringWithFormat:@"com.iotdesignshop.BeaconDemo.%@-%d-%d",newRegion.beaconUUID,[newRegion.beaconMajor intValue], [newRegion.beaconMinor intValue]];
        
        // This is the most specific case - we require a beacon with a matching UUID, Major, and Minor ID
        // in order to trigger.
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:[newRegion.beaconMajor shortValue] minor:[newRegion.beaconMinor shortValue] identifier:identifier];
    }
    else if(uuid && newRegion.beaconMajor)
    {
        // Create a unique ID for this notification
        NSString* identifier = [NSString stringWithFormat:@"com.iotdesignshop.BeaconDemo.%@-%d",newRegion.beaconUUID, [newRegion.beaconMajor intValue]];
        
        // This is a less specific case - we require a beacon with a matching UUID and Major ID to fire, but
        // the Minor ID can be any value.
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:[newRegion.beaconMajor shortValue]identifier:identifier];
    }
    else if(uuid)
    {
        // Create a unique ID for this notification
        NSString* identifier = [NSString stringWithFormat:@"com.iotdesignshop.BeaconDemo.%@",newRegion.beaconUUID];
        
        // This is the least specific case - any beacon with a matching UUID will fire regardless of Major
        // or Minor ID.
        region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:identifier];
    }
    
    return region;
}

-(HomeVoxNotificationRegion *)notificationRegionAtIndex:(NSUInteger)index
{
    return _activeNotificationRegions[index];
}

-(void)removeNotificationRegion:(HomeVoxNotificationRegion *)region
{
    // Remove region from our array
    [_activeNotificationRegions removeObject:region];
    
    // Attempt to build up a beacon region based on the BeaconNotificationRegion that was passed in
    CLBeaconRegion* beaconRegion = [self buildBeaconRegionForNotificationRegion:region];
    
    if (beaconRegion)
    {
        // Deregister with Core Location
        [_locationManager stopMonitoringForRegion:beaconRegion];
    }
    
    
    // Save notification list
    [self saveNotificationRegions];
    
}

-(void)removeNotificationRegionAtIndex:(NSUInteger)index
{
    // Pipe this through the other version of the call so that we handle Core Location
    // stuff in one spot only
    [self removeNotificationRegion:[self notificationRegionAtIndex:index]];
}

-(NSInteger)notificationRegionCount
{
    return [_activeNotificationRegions count];
}


#pragma mark CoreLocation Delegate

// This is a little helper that deals with comparing two NSNumbers which may be nil
-(BOOL)NSNumberEqual:(NSNumber*)number1 toNSNumber:(NSNumber*)number2
{
    // Deal with permutations of nil first
    
    // Both are nil? We consider that equal
    if (number1 == nil && number2 == nil)
        return YES;
    
    // One is nil, and other is not nil. That is considered unequal
    if ((number1 == nil && number2 != nil) || (number1 != nil && number2 == nil))
        return NO;
    
    // At this point, both are valid NSNumbers so we can compare them directly
    return [number1 isEqualToNumber:number2];
}

// This method takes care of handling user notifications for regions when state
// changes occur.
-(void)sendNotificationsForRegion:(CLBeaconRegion*)beaconRegion inState:(CLRegionState)state
{
    // We've got a region - we need to pattern match against our registered notifications to see
    // if we have a corresponding message for this event
    for (HomeVoxNotificationRegion* region in _activeNotificationRegions)
    {
        NSString* uuidString = [beaconRegion.proximityUUID UUIDString];
        
        // Check the parameters for a match against the region
        if ([region.beaconUUID isEqualToString:uuidString]
            && [self NSNumberEqual:region.beaconMajor toNSNumber:beaconRegion.major]
            && [self NSNumberEqual:region.beaconMinor toNSNumber:beaconRegion.minor])
        {
            
            // Create a local notification, and set up sounds
            UILocalNotification* notification = [[UILocalNotification alloc] init];
            notification.soundName = UILocalNotificationDefaultSoundName;
            
            
            // We have a match! Now, is this a hello or goodbye message?
            if (state == CLRegionStateInside && region.lastState != CLRegionStateInside)
            {
                // Do we have a hello message?
                if (region.helloMessage.length)
                {
                    // Send the hello message to the user
                    notification.alertBody = region.helloMessage;
                    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                }
            }
            else if (state == CLRegionStateOutside && region.lastState != CLRegionStateOutside)
            {
                if (region.goodbyeMessage.length)
                {
                    // Send the goodbye message to the user
                    notification.alertBody = region.goodbyeMessage;
                    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
                }
            }
            
            // Update the region state for the UI to use
            region.lastState = state;
            
            
            
            
        }
    }
    
    
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    // Scan our registered notifications to see if this state change
    // has a user message associated with it
    [self sendNotificationsForRegion:(CLBeaconRegion*)region inState:state];
    
    // Manage beacon ranging
    if (state == CLRegionStateInside)
    {
        // Start ranging the beacon
        [_locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
    else if (state == CLRegionStateOutside)
    {
        // Stop ranging the beacon
        [_locationManager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)beaconRegion
{
    for (CLBeacon* beacon in beacons)
    {
        // Update proximity and accuracy for all the beacons we can match in our
        // notification region array. This is used to update the UI primarily in the demo,
        // but might have other applications in a real world App.
        for (HomeVoxNotificationRegion *region in _activeNotificationRegions)
        {
            NSString* uuidString = [beaconRegion.proximityUUID UUIDString];
            
            // Check the parameters for a match against the region
            if ([region.beaconUUID isEqualToString:uuidString]
                && [self NSNumberEqual:region.beaconMajor toNSNumber:beaconRegion.major]
                && [self NSNumberEqual:region.beaconMinor toNSNumber:beaconRegion.minor])
            {
                region.lastProximity = beacon.proximity;
                region.lastAccuracy = beacon.accuracy;
                region.lastRSSI = beacon.rssi;
            }
        }
        
        // This is just for illustration purposes - lets us see the results of ranging in
        // the Xcode debugger.
        NSArray* proximityToString = @[@"Unknown", @"Immediate", @"Near", @"Far"];
        NSLog(@"\tProximity: %@ Accuracy: %f Rssi:%ld", proximityToString[beacon.proximity], beacon.accuracy, beacon.rssi);
    }
}

#pragma mark Persistence
-(void)saveNotificationRegions
{
    // Very simple - we just store the user notifications in a file in the documents directory
    NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* path = [NSString stringWithFormat:@"%@/notifications.dat", documentsDirectory];
    
    [NSKeyedArchiver archiveRootObject:_activeNotificationRegions toFile:path];
    
}

-(void)loadNotificationRegions
{
    // Attempt to load notifications if they are found in the documents directory
    NSString* documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* path = [NSString stringWithFormat:@"%@/notifications.dat", documentsDirectory];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        // Load the notifications from the documents folder
        _activeNotificationRegions = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        // Ask core location for an update on all the registered regions
        for (HomeVoxNotificationRegion *region in _activeNotificationRegions)
        {
            CLBeaconRegion* beaconRegion = [self buildBeaconRegionForNotificationRegion:region];
            [_locationManager  requestStateForRegion:beaconRegion];
        }
    }
    else
    {
        // No file to load - just initialize an empty array
        _activeNotificationRegions = [NSMutableArray array];
    }
    
}


@end
