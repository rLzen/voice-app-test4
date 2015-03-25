//
//  MasterViewController.m
//  VoiceAppTest_v04
//
//  Created by Richard Lorenzen on 3/22/15.
//  Copyright (c) 2015 Richard Lorenzen. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "BeaconTableViewCell.h"
#import "HomeVoxNotificationRegion.h"
#import "AppDelegate.h"

@interface MasterViewController ()

@property (strong, nonatomic) NSTimer* updateTimer;
@property (nonatomic, strong) Slt *slt;
@property (nonatomic, copy) NSString *pathToFirstDynamicallyGeneratedLanguageModel;
@property (nonatomic, copy) NSString *pathToFirstDynamicallyGeneratedDictionary;
@property (nonatomic, strong) OEFliteController *fliteController;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewNotification:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // Testing accesory browser
    self.accessoryBrowser = [[HMAccessoryBrowser alloc] init];
    self.accessoryBrowser.delegate = self;
    
    [self.accessoryBrowser startSearchingForNewAccessories];
    
    
    // I NEED TO DOCUMENT THIS BETTER
    self.fliteController = [[OEFliteController alloc] init];
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    self.openEarsEventsObserver.delegate = self;
    self.slt = [[Slt alloc] init];
    
    // Testing OpenEars API
    
    [OEPocketsphinxController sharedInstance].verbosePocketSphinx = TRUE;
    
    
    [self.openEarsEventsObserver setDelegate:self];
    
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil]; // Call this before setting any OEPocketsphinxController characteristics
    
    NSArray *firstLanguageArray = @[@"DEVICE",
                                    @"TURN ON",
                                    @"TURN OFF",
                                    @"GO",
                                    @"LEFT",
                                    @"MODE",
                                    @"RIGHT",
                                    @"LIGHTS"];
    
    OELanguageModelGenerator *languageModelGenerator = [[OELanguageModelGenerator alloc] init];
    
    // languageModelGenerator.verboseLanguageModelGenerator = TRUE; // Uncomment me for verbose language model generator debug output.
    
    NSError *error = [languageModelGenerator generateLanguageModelFromArray:firstLanguageArray withFilesNamed:@"FirstOpenEarsDynamicLanguageModel" forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]];
    
    if(error) {
        NSLog(@"Dynamic language generator reported error %@", [error description]);
    } else {
        self.pathToFirstDynamicallyGeneratedLanguageModel = [languageModelGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"FirstOpenEarsDynamicLanguageModel"];
        self.pathToFirstDynamicallyGeneratedDictionary = [languageModelGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"FirstOpenEarsDynamicLanguageModel"];
    }
}






#pragma mark - OpenEars

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis
                         recognitionScore:(NSString *)recognitionScore
                              utteranceID:(NSString *)utteranceID {
    
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    
   // self.heardTextView.text = [NSString stringWithFormat:@"Heard: \"%@\"", hypothesis]; // Show it in the status box.
    
    // repeat back the command that we heard with the voice we've chosen.
    [self.fliteController say:[NSString stringWithFormat:@"You said %@",hypothesis] withVoice:self.slt];
    
}

- (void) pocketsphinxDidStartListening {
    NSLog(@"Pocketsphinx is now listening.");
    
    //self.statusTextView.text = @"Pocketsphinx is now listening.";
    
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void)pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void)pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void)testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)insertNewObject:(id)sender {
//    if (!self.objects) {
//        self.objects = [[NSMutableArray alloc] init];
//    }
//    [self.objects insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}

-(void)viewWillAppear:(BOOL)animated
{
    // Reload the data in our table in case records were added or changed
    [self.tableView reloadData];
    
    // We start a timer to update the cells in the view every second
    self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                        target:self
                                                      selector:@selector(updateTable:) userInfo:nil repeats:YES];
   
}

- (void)insertNewNotification:(id)sender
{
    // This handler is called when the "Add" button is pressed - we
    // create a new notification region in the detail view
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

-(void)viewWillDisappear:(BOOL)animated
{
    // Stop our update timer while the view is not in the foreground
    [_updateTimer invalidate];
    _updateTimer = nil;
    [self.accessoryBrowser stopSearchingForNewAccessories];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (indexPath)
        {
            // Our app delegate owns all of the notification regions, so we pull the value from there
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            // Tell the destination controller that we're editing an existing item by passing
            // that item through.
            [[segue destinationViewController] setDetailItem:[delegate notificationRegionAtIndex:indexPath.row]];
        }
        
    }}

#pragma mark - Table View

-(void)updateTable:(NSTimer*)timer
{
    // This is a timer callback that gets hit every 1s to
    // refresh the cells in the table for new ranging and
    // state information.
    [self.tableView reloadData];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return [delegate notificationRegionCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BeaconTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Our app delegate owns all of the notification regions, so we retrieve the record from it
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    HomeVoxNotificationRegion *region = [delegate notificationRegionAtIndex:indexPath.row];
    
    // Convert beacon proximity to an English description
    if (region.lastState == CLRegionStateInside)
    {
        // We're in the region, so use proximity values from the last ranging
        // operation to update the view
        NSArray* proximityDescriptions = @[ @"Unknown", @"Immediate", @"Near", @"Far"];
        cell.beaconProximityLabel.text = proximityDescriptions[region.lastProximity];
        cell.beaconRangeLabel.text = [NSString stringWithFormat:@"%.2fm", region.lastAccuracy];
        cell.beaconRSSILabel.text = [NSString stringWithFormat:@"%lddB", region.lastRSSI];
        
        // this a test for start listening
        // range will be required
        if (![OEPocketsphinxController sharedInstance].isListening) {
            
            [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:self.pathToFirstDynamicallyGeneratedLanguageModel dictionaryAtPath:self.pathToFirstDynamicallyGeneratedDictionary acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO];
        }

        
    }
    else
    {
        // We're outside the region, let the user know
        cell.beaconProximityLabel.text = @"Not In Range";
        cell.beaconRangeLabel.text = @"0.0m";
        cell.beaconRSSILabel.text = @"0dB";
        
        // stops listening
        // taking too long to stop listening
        if ([OEPocketsphinxController sharedInstance].isListening) {
            [[OEPocketsphinxController sharedInstance] stopListening];
        }
    }
    
    // ID labels so we can pick out which cell is which
    cell.beaconUUIDLabel.text = region.beaconUUID;
    cell.beaconIDLabel.text = [NSString stringWithFormat:@"Major: %@ Minor: %@", region.beaconMajor?[region.beaconMajor stringValue]:@"All", region.beaconMinor?[region.beaconMinor stringValue]:@"All"];
    
    

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // app delegate owns all of the notification regions, so we tell it to
        // remove the corresponding one to the user's selection
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
     
        
        [delegate removeNotificationRegionAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

@end
