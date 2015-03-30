//
//  DetailAccessoryViewController.h
//  VoiceAppTest_v04
//
//  Created by Richard Lorenzen on 3/25/15.
//  Copyright (c) 2015 Richard Lorenzen. All rights reserved.
//

@import UIKit;
@import HomeKit;
@class HomeVoxNotificationRegion;
@class DetailAccessoryViewController;

@protocol ModifyAccessoryDelegate <NSObject>

- (void)accessoryViewController:(DetailAccessoryViewController *)viewController
               didSaveAccessory:(HMAccessory *)accessory;

@end


@interface DetailAccessoryViewController : UITableViewController

@property (nonatomic) HMAccessory *accessory;
@property (nonatomic) id<ModifyAccessoryDelegate> delegate;
@property (strong, nonatomic) HomeVoxNotificationRegion *accessoryItem;

@end
