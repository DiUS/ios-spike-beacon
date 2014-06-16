//
//  RecordDataViewController.h
//  iBeaconExperiments
//
//  Created by Brenton Crowley on 16/06/2014.
//  Copyright (c) 2014 DiUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseExperimentViewController.h"

@interface RecordDataViewController : BaseExperimentViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *header;
@property (weak, nonatomic) IBOutlet UITextField *distanceField;
@property (weak, nonatomic) IBOutlet UITextField *filenameField;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
