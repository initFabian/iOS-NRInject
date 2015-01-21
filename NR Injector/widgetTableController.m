//
//  widgetTableController.m
//  NR Inject
//
//  Created by Fabian Buentello on 1/20/15.
//  Copyright (c) 2015 Fabian Buentello. All rights reserved.
//

#import "widgetTableController.h"
#import "Config.h"

@implementation widgetTableController
@synthesize ipAddress,password;

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mioty.NR_Injector"];
    self.ipAddress = [myDefaults objectForKey:@"ip"];
    self.password = [myDefaults objectForKey:@"password"];
    NSLog(@"widgetPerformUpdateWithCompletionHandler: NSUserDefaults: %@",self.ipAddress);
    NSLog(@"widgetPerformUpdateWithCompletionHandler: NSUserDefaults: %@",self.password);

    [self getData];
    completionHandler(NCUpdateResultNewData);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad: NSUserDefaults: %@",self.ipAddress);
    NSLog(@"viewDidLoad: NSUserDefaults: %@",self.password);
    self.preferredContentSize = CGSizeMake(0, 300);
    [self getData];
}

-(void) getData {
    NSLog(@"getData was called");

    if (self.ipAddress != nil) {
    
    _mConnect = [mConnection new];
    widgetTableController * __weak weakSelf = self;
    
    NSLog(@"getData was called");
    [_mConnect getNodesFromIP:self.ipAddress
                  andPassword:self.password
                 withCallBack:^(bool error, NSMutableArray *response) {
                     if (!error) {
                         NSLog(@"response: %@",response);
                         weakSelf.cellTitles = response;
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [weakSelf.tableView reloadData];
                         });
                         
                     } else {
                         weakSelf.cellTitles = response;
                         dispatch_async(dispatch_get_main_queue(), ^{
                             [weakSelf.tableView reloadData];
                             NSLog(@"response was empty");
                         });
                     }
                 }];
        } else {
             NSLog(@"response was empty");
        }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.cellTitles count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *obj = [_cellTitles objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [obj objectForKey:@"name"];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //stuff
    //as last line:
    [self triggerNodeAtIndex:indexPath];
    [self flashAnimation:[self.tableView cellForRowAtIndexPath:indexPath]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark - Triggered Methods

-(void)triggerNodeAtIndex:(NSIndexPath *)nIndex {
    NSString *pid = [[_cellTitles objectAtIndex:nIndex.row] objectForKey:@"id"];
    
    [_mConnect triggerNodeWithIP:self.ipAddress
                     andPassword:self.password
                       andNodeID:pid withCallBack:^(bool error, NSMutableArray *response) {
                           NSLog(@"Triggered Node Response: %@",response);
                       }];
}

- (void)flashAnimation:(UITableViewCell *)cell{
    UIView *flash = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    flash.backgroundColor = UIColorFromRGB(appColor);
    
    UILabel *yourLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,cell.frame.size.width, cell.frame.size.height)];
    yourLabel.textAlignment = NSTextAlignmentCenter;
    [yourLabel setText:@"Triggered!"];
    [yourLabel setTextColor:[UIColor whiteColor]];
    [yourLabel setBackgroundColor:[UIColor clearColor]];
    [yourLabel setFont:[UIFont fontWithName: @"Trebuchet MS" size: 20.0f]];
    [flash addSubview:yourLabel];
    [cell addSubview:flash];
    [UIView animateWithDuration: 1.0
                     animations: ^{
                         flash.alpha = 0.0;
                     }
                     completion: ^(BOOL finished) {
                         [flash removeFromSuperview];
                     }
     ];
}


@end
