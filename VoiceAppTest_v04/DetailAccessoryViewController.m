//
//  DetailAccessoryViewController.m
//  VoiceAppTest_v04
//
//  Created by Richard Lorenzen on 3/25/15.
//  Copyright (c) 2015 Richard Lorenzen. All rights reserved.
//

#import "DetailAccessoryViewController.h"
#import "DetailViewController.h"
#import "MasterViewController.h"
#import "HomeVoxNotificationRegion.h"
#import "AppDelegate.h"

typedef NS_ENUM(NSUInteger, AddAccessoryTableViewSection) {
    AddAccessoryTableViewSectionName = 0,
    AddAccessoryTableViewSectionBeacons,
    AddAccessoryTableViewSectionIdentify,
};

@interface DetailAccessoryViewController () <HMHomeDelegate, HMAccessoryDelegate>

@property (nonatomic) NSArray *regions;


@property (nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic) HomeVoxNotificationRegion *selectedRegion;
@property (nonatomic) IBOutlet UITextField *nameField;
@property (nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;

@property (nonatomic) dispatch_group_t saveAccessoryGroup;

@property (nonatomic) BOOL editingExistingAccessory;
@property (nonatomic) BOOL didEncounterError;


@end

@implementation DetailAccessoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.accessory.delegate = self;
    
    // Create a dispatch_group to keep track of all the necessary parts
    // of accessory modification.
    self.saveAccessoryGroup = dispatch_group_create();
    
    // Create an activity indicator so display in place of the 'Add' button.
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    // If the accessory belongs to the home already, we are in 'edit' mode.
    if (self.editingExistingAccessory) {
        // Show 'save' instead of 'add.'
        self.addButton.title = NSLocalizedString(@"Save", @"Save");
    } else {
        // If we're not editing an existing accessory, then let the back
        // button show in the left.
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    // Put the accessory's name in the 'name' field.
    [self resetNameField];
    
    // Register a cell for the rooms.
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"BeaconCell"];
}

- (void)hideActivityIndicator {
    [self.activityIndicator stopAnimating];
    self.navigationItem.rightBarButtonItem = self.addButton;
}

/**
 *  Temporarily replaces the 'Add' or 'Save' button with an activity indicator.
 */
- (void)showActivityIndicator {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (IBAction)didTapAddButton {
    // Save some variables to use inside the block.
    NSString *name = [self trimmedName];
    [self showActivityIndicator];
    
    if (self.editingExistingAccessory) {
        [self updateName:name forAccessory:self.accessory];
    }
    dispatch_group_notify(self.saveAccessoryGroup, dispatch_get_main_queue(), ^{
        [self hideActivityIndicator];
        if (!self.didEncounterError) {
            [self dismiss:nil];
        }
    });
}

- (IBAction)dismiss:(id)sender {
    [self.delegate accessoryViewController:self didSaveAccessory:self.accessory];
    if (self.editingExistingAccessory) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)updateName:(NSString *)name forAccessory:(HMAccessory *)accessory {
    if ([accessory.name isEqualToString:name]) {
        return;
    }
    dispatch_group_enter(self.saveAccessoryGroup);
    [accessory updateName:name completionHandler:^(NSError *error) {
        if (error) {
            self.didEncounterError = YES;
        }
        dispatch_group_leave(self.saveAccessoryGroup);
    }];
}

- (void)identifyAccessory {
    [self.accessory identifyWithCompletionHandler:^(NSError *error) {
        if (error) {
           
        }
    }];
}

- (void)reloadTable {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)resetNameField {
    NSString *action;
    if (self.editingExistingAccessory) {
        action = NSLocalizedString(@"Edit %@", @"Edit Accessory");
    } else {
        action = NSLocalizedString(@"Add %@", @"Add Accessory");
    }
    self.navigationItem.title = [NSString stringWithFormat:action, self.accessory.name];
    self.nameField.text = self.accessory.name;
    [self enableAddButtonIfApplicable];
}

- (void)enableAddButtonIfApplicable {
    self.addButton.enabled = [self trimmedName].length > 0;
}

- (NSString *)trimmedName {
    return [self.nameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (IBAction)didChangeNameField:(id)sender {
    [self enableAddButtonIfApplicable];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.accessory.blocked) {
        return 4;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == AddAccessoryTableViewSectionBeacons) {
        return _regions.count;
    }
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == AddAccessoryTableViewSectionBeacons) {
        return UITableViewAutomaticDimension;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == AddAccessoryTableViewSectionBeacons) {
        return [self tableView:tableView roomCellForRowAtIndexPath:indexPath];
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView roomCellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BeaconCell" forIndexPath:indexPath];

     HomeVoxNotificationRegion *region = [[HomeVoxNotificationRegion alloc] init];
    
    cell.textLabel.text = region.beaconUUID;
    
    // Put a checkmark on the selected room.
    if (region == self.selectedRegion) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case AddAccessoryTableViewSectionBeacons: {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:AddAccessoryTableViewSectionBeacons] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        case AddAccessoryTableViewSectionIdentify: {
            [self identifyAccessory];
            break;
        }
        default:
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
}

- (void)accessoryDidUpdateName:(HMAccessory *)accessory {
    [self resetNameField];
}


@end
