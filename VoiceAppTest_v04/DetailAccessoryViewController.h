//
//  DetailAccessoryViewController.h
//  VoiceAppTest_v04
//
//  Created by Richard Lorenzen on 3/25/15.
//  Copyright (c) 2015 Richard Lorenzen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HomeVoxNotificationRegion;
@interface DetailAccessoryViewController : UIViewController


@property (strong, nonatomic) IBOutlet UITextField *accessoryUUIDTextField;
@property (strong, nonatomic) IBOutlet UITextField *connectedBeaconUUIDTextField;

@property (strong, nonatomic) HomeVoxNotificationRegion *accessoryItem;

@end
