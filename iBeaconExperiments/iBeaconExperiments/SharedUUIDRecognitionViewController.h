//
//  SharedUUIDRecognitionViewController.h
//  iBeaconExperiments
//
//  Created by Brenton Crowley on 12/06/2014.
//  Copyright (c) 2014 DiUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseExperimentViewController.h"

@interface SharedUUIDRecognitionViewController : BaseExperimentViewController
<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
