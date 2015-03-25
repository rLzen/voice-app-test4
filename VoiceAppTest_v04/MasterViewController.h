//
//  MasterViewController.h
//  VoiceAppTest_v04
//
//  Created by Richard Lorenzen on 3/22/15.
//  Copyright (c) 2015 Richard Lorenzen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEEventsObserver.h>
#import <OpenEars/OEFliteController.h>
#import <Slt/Slt.h>
#import <HomeKit/HomeKit.h>

@interface MasterViewController : UITableViewController <AVAudioRecorderDelegate,
AVAudioPlayerDelegate, OEEventsObserverDelegate, HMAccessoryBrowserDelegate>

@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;
@property HMAccessoryBrowser *accessoryBrowser;

@end

