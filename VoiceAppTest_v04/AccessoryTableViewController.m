//
//  AccessoryTableViewController.m
//  VoiceAppTest_v04
//
//  Created by Richard Lorenzen on 3/25/15.
//  Copyright (c) 2015 Richard Lorenzen. All rights reserved.
//

#import "AccessoryTableViewController.h"
#import "DetailAccessoryViewController.h"
#import "AppDelegate.h"
#import "HomeVoxNotificationRegion.h"


@interface AccessoryTableViewController () 
@property HMAccessoryBrowser *accessoryBrowser;
@property EAWiFiUnconfiguredAccessoryBrowser *externalAccessoryBrowser;

// Alphabetized cache of accessories.
@property (nonatomic) NSArray *displayedAccessories;
@property (nonatomic) NSMutableArray *addedAccessories;

// A temporary variable to keep track of an accessory that's being configured through WAC.
@property (nonatomic) NSString *externalAccessoryName;

// A temporary variable to hold an HMAccessory that's been selected to be configured.
@property (nonatomic) HMAccessory *selectedAccessory;

@property (nonatomic) dispatch_queue_t externalAccessorySyncQueue;

@end

@implementation AccessoryTableViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    self.accessoryBrowser = [HMAccessoryBrowser new];
    
    self.accessoryBrowser.delegate = self;
    self.addedAccessories = [NSMutableArray array];
    
    self.externalAccessorySyncQueue = dispatch_queue_create("com.rclzen.HMCatalog.externalSyncQueue", DISPATCH_QUEUE_SERIAL);
    
    // We can't use the ExternalAccessory framework on the iPhone simulator.
#if !TARGET_IPHONE_SIMULATOR
    self.externalAccessoryBrowser = [[EAWiFiUnconfiguredAccessoryBrowser alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
#endif
    [self startBrowsing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadTable];
}

- (void)dealloc {
    [self stopBrowsing];
}

/**
 *  Closes itself.
 */
- (IBAction)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  Starts browsing for accessories.
 */
- (void)startBrowsing {
    [self.accessoryBrowser startSearchingForNewAccessories];
    [self.externalAccessoryBrowser startSearchingForUnconfiguredAccessoriesMatchingPredicate:nil];
}

/**
 *  Stops browsing for accessories.
 */
- (void)stopBrowsing {
    [self.accessoryBrowser stopSearchingForNewAccessories];
    [self.externalAccessoryBrowser stopSearchingForUnconfiguredAccessories];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewAccessory:(id)sender {
    [self performSegueWithIdentifier:@"showDetailAccessory" sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    NSUInteger rows = self.displayedAccessories.count;
    return rows;
   
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id accessory = self.displayedAccessories[indexPath.row];
    
    NSString *reuseIdentifier = @"AccessoryCell";
    
    // If this is an accessory that was recently added, use a different prototype.
    if ([self.addedAccessories containsObject:accessory]) {
        reuseIdentifier = @"AddedAccessoryCell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [accessory name];
    return cell;


        
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

/**
 * If a user selects on a cell that contains an HMAccessory, then show the configuration UI.
 * Otherwise, if the user selects on a cell that contains an unconfigured external accessory, show the
 * ExternalAccessory framework's configuration UI, and then show our own once that's happened.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id accessory = self.displayedAccessories[indexPath.row];
    if ([accessory isKindOfClass:[HMAccessory class]]) {
        [self configureAccessory:accessory];
    } else if ([accessory isKindOfClass:[EAWiFiUnconfiguredAccessory class]]) {
        [self.externalAccessoryBrowser configureAccessory:accessory withConfigurationUIOnViewController:self];
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"showAccessoryDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (indexPath)
        {
            // Our app delegate owns all of the notification regions, so we pull the value from there
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            // Tell the destination controller that we're editing an existing item by passing
            // that item through.
            [[segue destinationViewController] setAccessoryItem:[delegate notificationRegionAtIndex:indexPath.row]];
        }
        
    }

}


#pragma mark - Accessory Storage

/**
 *  Resets the saved accessory list to both the discovered accessories
 *  and the ones added in this session.
 */
- (void)resetDisplayedAccessories {
    self.displayedAccessories = [self allAccessories];
}

/**
 *  @discussion Stores an alphabetized cache of the accessory browser's accessories.
 *  @return The stored accessoryBrowser's discoveredAccessories, alphabetized.
 */
- (NSArray *)allAccessories {
    NSMutableArray *allAccessories = [NSMutableArray array];
    NSArray *discoveredAccessories = self.accessoryBrowser.discoveredAccessories;
    if (discoveredAccessories) {
        [allAccessories addObjectsFromArray:discoveredAccessories];
    }
    [allAccessories addObjectsFromArray:self.addedAccessories];
    NSArray *externalAccessories = self.externalAccessoryBrowser.unconfiguredAccessories.allObjects;
    if (externalAccessories) {
        // ExternalAcessory framework may still contain an accessory for a little while after it's been configured.
        // If there is a HomeKit accessory with the same name as any external accessory, filter out the external accessory.
        NSPredicate *existingHomeKitAccessoryPredicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return ![[allAccessories valueForKeyPath:@"@distinctUnionOfObjects.name"] containsObject:evaluatedObject];
        }];
        NSArray *filteredExternalAccessories = [externalAccessories filteredArrayUsingPredicate:existingHomeKitAccessoryPredicate];
        [allAccessories addObjectsFromArray:filteredExternalAccessories];
    }
    
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                     ascending:YES
                                                                      selector:@selector(caseInsensitiveCompare:)];
    return [allAccessories sortedArrayUsingDescriptors:@[nameDescriptor]];
}

/**
 *  Invalidates our cache of alphabetized accessories and reloads the tableView's data.
 */
- (void)reloadTable {
    [self resetDisplayedAccessories];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

/**
 * Looks up the indexPath of the accessory and calls performSegue with
 * the appropriate cell as the sender.
 */
- (void)configureAccessory:(HMAccessory *)accessory {
    NSUInteger index = [self.displayedAccessories indexOfObject:accessory];
    // If we're not displaying this accessory, don't attempt to configure it.
    if (index == NSNotFound) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.selectedAccessory = accessory;
        [self performSegueWithIdentifier:@"Add Accessory" sender:self];
    });
}

/**
 *  Searches for an HMAccessory within the current displayed accessories list
 *  with a name that matches the passed-in name.
 *
 *  @param name The name we're looking for.
 *
 *  @return An HMAccessory that matches the provided name, or nil if one was not found.
 */
- (HMAccessory *)unconfiguredHomeKitAccessoryWithName:(NSString *)name {
    if (!name)
        return nil;
    for (HMAccessory *accessory in self.displayedAccessories) {
        if ([accessory isKindOfClass:HMAccessory.class] && [accessory.name isEqualToString:name]) {
            return accessory;
        }
    }
    return nil;
}


#pragma mark - EAWiFiUnconfiguredAccessoryBrowserDelegate methods

- (void)accessoryBrowser:(EAWiFiUnconfiguredAccessoryBrowser *)browser didFindUnconfiguredAccessories:(NSSet *)accessories {
    [self reloadTable];
}

- (void)accessoryBrowser:(EAWiFiUnconfiguredAccessoryBrowser *)browser didRemoveUnconfiguredAccessories:(NSSet *)accessories {
    [self reloadTable];
}

- (void)accessoryBrowser:(EAWiFiUnconfiguredAccessoryBrowser *)browser didUpdateState:(EAWiFiUnconfiguredAccessoryBrowserState)state {
    [self reloadTable];
    // Required delegate method.
}

- (void)accessoryBrowser:(EAWiFiUnconfiguredAccessoryBrowser *)browser didFinishConfiguringAccessory:(EAWiFiUnconfiguredAccessory *)accessory withStatus:(EAWiFiUnconfiguredAccessoryConfigurationStatus)status {
    if (status != EAWiFiUnconfiguredAccessoryConfigurationStatusSuccess) {
        return;
    }
    // Update our stored accessory name, marking that the accessory should be configured
    // once it appears to HomeKit.
    dispatch_async(self.externalAccessorySyncQueue, ^{
        HMAccessory *foundAccessory = [self unconfiguredHomeKitAccessoryWithName:accessory.name];
        if (foundAccessory) {
            [self configureAccessory:foundAccessory];
        } else {
            self.externalAccessoryName = accessory.name;
        }
    });
}



@end
