//
//  AppDelegate.m
//  iBeaconExperiments
//
//  Created by Brenton Crowley on 12/06/2014.
//  Copyright (c) 2014 DiUS. All rights reserved.
//

#import "AppDelegate.h"
#import "SharedUUIDRecognitionViewController.h"
#import "BaseExperimentViewController.h"
#import "AveragerViewController.h"
#import "RecordDataViewController.h"
#import "AppleVsEstimoteViewController.h"

@interface AppDelegate() <UITableViewDataSource, UITableViewDelegate>

@property NSArray *experimentVCClasses;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // If unit testing skip setup
    #if DEBUG
        if (getenv("runningTests"))
            return YES;
    #endif
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    self.experimentVCClasses = @[
                                 [SharedUUIDRecognitionViewController class],
                                 [AveragerViewController class],
                                 [RecordDataViewController class],
                                 [AppleVsEstimoteViewController class]
                                 ];
    
    UITableViewController *rootVC = [[UITableViewController alloc] init];
    rootVC.tableView.delegate = self;
    rootVC.tableView.dataSource = self;
    UINavigationController *navCtrl =
        [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    self.window.rootViewController = navCtrl;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.experimentVCClasses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellID];
    }
    
    Class  class =
        [self.experimentVCClasses objectAtIndex:indexPath.row];
    
    if (class)
    {
        cell.textLabel.text = NSStringFromClass(class);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
        cell.textLabel.text = @"Undefined";
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
        didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UINavigationController *navCtrl =
        (UINavigationController *)self.window.rootViewController;

    Class class = [self.experimentVCClasses objectAtIndex:indexPath.row];
    UIViewController *vc = [[class alloc] init];
    [navCtrl pushViewController:vc animated:YES];
}

@end
