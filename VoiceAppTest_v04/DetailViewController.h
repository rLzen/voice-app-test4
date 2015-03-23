//
//  DetailViewController.h
//  VoiceAppTest_v04
//
//  Created by Richard Lorenzen on 3/22/15.
//  Copyright (c) 2015 Richard Lorenzen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeVoxNotificationRegion;

@interface DetailViewController : UIViewController

@property (strong, nonatomic) HomeVoxNotificationRegion* detailItem;

@property (strong, nonatomic) IBOutlet UITextField* beaconUUIDTextField;
@property (strong, nonatomic) IBOutlet UITextField* beaconMajorTextField;
@property (strong, nonatomic) IBOutlet UITextField* beaconMinorTextField;
@property (strong, nonatomic) IBOutlet UITextField* helloMessageTextField;
@property (strong, nonatomic) IBOutlet UITextField* goodbyeMessageTextField;

@end

