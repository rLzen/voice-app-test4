//
//  DetailAccessoryViewController.m
//  VoiceAppTest_v04
//
//  Created by Richard Lorenzen on 3/25/15.
//  Copyright (c) 2015 Richard Lorenzen. All rights reserved.
//

#import "DetailAccessoryViewController.h"
#import "HomeVoxNotificationRegion.h"
#import "AppDelegate.h"


@interface DetailAccessoryViewController ()

@end

@implementation DetailAccessoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setAccessoryItem:(id)newAccessoryItem {
    if (_accessoryItem != newAccessoryItem) {
        _accessoryItem = newAccessoryItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // If an existing item was passed into the view, init the fields
    // with the values from the item
    
    if (_accessoryItem)
    {
        // Init Beacon UUID
        _accessoryUUIDTextField.text = _accessoryItem.accessoryUUID;
        _connectedBeaconUUIDTextField.text = _accessoryItem.beaconUUID;
       
    }
    else
    {
        // Default values - this is Beacon UUID
       _connectedBeaconUUIDTextField.text  = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";
        _accessoryUUIDTextField.text = @"23385640-9FFE-4304-A3D9-03581A7930BB";
    }
    
}
- (IBAction)RegisterAccessory:(id)sender {
    
    HomeVoxNotificationRegion* region = [[HomeVoxNotificationRegion alloc] init];
    
    // Copy UI values into the new region object
    region.accessoryUUID = _accessoryUUIDTextField.text;
    region.beaconUUID = _connectedBeaconUUIDTextField.text;

    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // If this is an update, unregister the old region first
    if (_accessoryItem)
    {
        // Remove the old region
        [delegate removeNotificationRegion:_accessoryItem];
    }
    
    // Register the region
    [delegate addNotificationRegion:region];
    
    
    
    // Back to the master view
    [self.navigationController popViewControllerAnimated:YES];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
