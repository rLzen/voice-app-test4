//
//  BeaconTableViewCell.h
//  VoiceAppTest_v04
//
//  Created by Richard Lorenzen on 3/22/15.
//  Copyright (c) 2015 Richard Lorenzen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeaconTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel* beaconUUIDLabel;
@property (strong, nonatomic) IBOutlet UILabel* beaconIDLabel;
@property (strong, nonatomic) IBOutlet UILabel* beaconProximityLabel;
@property (strong, nonatomic) IBOutlet UILabel* beaconRangeLabel;
@property (strong, nonatomic) IBOutlet UILabel* beaconRSSILabel;

@end
