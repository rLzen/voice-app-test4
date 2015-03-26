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
#import "AccessoryTableViewCell.h"

@interface AccessoryTableViewController ()

@end

@implementation AccessoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewAccessory:)];
    self.navigationItem.rightBarButtonItem = addButton;

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

    // Return the number of rows in the section.
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return [delegate notificationRegionCount];
   
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AccessoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccessoryCell"
                                                            forIndexPath:indexPath];
    
    // Configure the cell...
    // Our app delegate owns all of the notification regions, so we retrieve the record from it
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    HomeVoxNotificationRegion *region = [delegate notificationRegionAtIndex:indexPath.row];
    
    cell.accessoryUUIDLabel.text = region.accessoryUUID;
    cell.accessoryBeaconUUIDLabel.text = region.beaconUUID;
    
    
    // ID labels so we can pick out which cell is which
    
   
    
    

    
    
    return cell;
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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

@end
