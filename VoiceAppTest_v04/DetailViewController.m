//
//  DetailViewController.m
//  VoiceAppTest_v04
//
//  Created by Richard Lorenzen on 3/22/15.
//  Copyright (c) 2015 Richard Lorenzen. All rights reserved.
//

#import "DetailViewController.h"
#import "BeaconTableViewCell.h"
#import "HomeVoxNotificationRegion.h"
#import "AppDelegate.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // If an existing item was passed into the view, we init the fields
    // with the values from the item
    if (_detailItem)
    {
        // Init Beacon UUID
        _beaconUUIDTextField.text = _detailItem.beaconUUID;
        
        // Init Beacon Major (if one is specified)
        if (_detailItem.beaconMajor)
        {
            _beaconMajorTextField.text = [_detailItem.beaconMajor stringValue];
        }
        
        // Init Beacon Minor (if one is specified)
        if (_detailItem.beaconMinor)
        {
            _beaconMinorTextField.text = [_detailItem.beaconMinor stringValue];
        }
        
        // Messages
        _helloMessageTextField.text = _detailItem.helloMessage;
        _goodbyeMessageTextField.text = _detailItem.goodbyeMessage;
    }
    else
    {
        // Default values - this is the IoT Design Shop Default Beacon UUID
        _beaconUUIDTextField.text = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // We don't do that much validation, but it's easy to make a mistake
    // entering a UUID, so we check the UUID field to make sure it's a valid
    // UUID.
    if (textField == _beaconUUIDTextField)
    {
        if (textField.text.length)
        {
            NSUUID* valid = [[NSUUID alloc] initWithUUIDString:textField.text];
            
            if (!valid)
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid UUID" message:@"The UUID you entered does not appear to be valid. Please double check it." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    
    // To keep it simple, we have return just dismiss the keyboard
    [textField resignFirstResponder];
    
    return YES;
}

// Called when user clicks the "Register Notification" button
-(IBAction)registerNotification:(id)sender
{
    HomeVoxNotificationRegion* region = [[HomeVoxNotificationRegion alloc] init];
    
    // Copy our UI values into the new region object
    region.beaconUUID = _beaconUUIDTextField.text;
    
    if (_beaconMajorTextField.text.length)
    {
        region.beaconMajor = [NSNumber numberWithInteger:[_beaconMajorTextField.text integerValue]];
    }
    
    if (_beaconMinorTextField.text.length)
    {
        region.beaconMinor = [NSNumber numberWithInteger:[_beaconMinorTextField.text integerValue]];
    }
    
    region.helloMessage = _helloMessageTextField.text;
    region.goodbyeMessage = _goodbyeMessageTextField.text;
    
    
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // If this is an update, we unregister the old region first
    if (_detailItem)
    {
        // Remove the old region
        [delegate removeNotificationRegion:_detailItem];
    }
    
    // Register the region
    [delegate addNotificationRegion:region];
    
    
    
    // Back to the master view
    [self.navigationController popViewControllerAnimated:YES];
}


@end
