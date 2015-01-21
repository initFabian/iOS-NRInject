//
//  widgetTableController.h
//  NR Inject
//
//  Created by Fabian Buentello on 1/20/15.
//  Copyright (c) 2015 Fabian Buentello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mConnection.h"
#import <NotificationCenter/NotificationCenter.h>

@interface widgetTableController : UITableViewController <NCWidgetProviding>

@property(strong, nonatomic) mConnection *mConnect;
@property(strong, nonatomic) NSMutableArray *cellTitles;
@property (strong, nonatomic) NSString *ipAddress;
@property (strong, nonatomic) NSString *password;

@end
