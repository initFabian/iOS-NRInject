//
//  MainTableViewCTRL.m
//  NR Inject
//
//  Created by Fabian Buentello on 1/20/15.
//  Copyright (c) 2015 Fabian Buentello. All rights reserved.
//

#import "MainTableViewCTRL.h"

//Classes
#import "Config.h"
#import "NrCell.h"
#import "NSString+FontAwesome.h"
#import "mConnection.h"
#import "SettingsController.h"

@interface MainTableViewCTRL ()

@property (strong, nonatomic) NSMutableArray *cellTitles;
@property (nonatomic) bool pulledToGetData;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIButton *settingsBtn;
@property (strong, nonatomic) NSString *Address;
@property (strong, nonatomic) NSString *cloudURL;
@property (strong, nonatomic) NSString *password;
@end

//mConnection
mConnection *_mConnect;

UIImageView *blurredBackGround;
UILabel *backgroundMessage;


@implementation MainTableViewCTRL
@synthesize activityIndicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mioty.NR_Injector"];
//    NSLog(@"viewDidLoad NSUserDefaults: %@",[myDefaults objectForKey:@"ip"]);
//    NSLog(@"viewDidLoad NSUserDefaults: %@",[myDefaults objectForKey:@"password"]);
    


    
    //SETTINGS BUTTON
    [_settingsBtn setTitle:[NSString fontAwesomeIconStringForEnum:FACogs] forState:UIControlStateNormal];
    
    //ACTIVITY INDICATOR
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    [self navigationItem].rightBarButtonItem = barButton;
    [self.activityIndicator setColor:[UIColor whiteColor]];
    
    //BACKGROUND IMAGE
    blurredBackGround = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nodeRed"]];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    visualEffectView.frame = self.tableView.bounds;
    [blurredBackGround addSubview:visualEffectView];
    
    //set blurred image to background
    [self.tableView setBackgroundView:blurredBackGround];
    
    // Display a message when the table is empty
    backgroundMessage = [[UILabel alloc] initWithFrame:self.tableView.frame];
    
    backgroundMessage.text = @"No data is currently available. Please pull down to refresh.";
    backgroundMessage.textColor = [UIColor blackColor];
    backgroundMessage.numberOfLines = 0;
    backgroundMessage.textAlignment = NSTextAlignmentCenter;
    backgroundMessage.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
    [backgroundMessage sizeToFit];
    backgroundMessage.center = self.tableView.center;
    
    
    //PULL TO REFRESH
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(pulledRefresh) forControlEvents:UIControlEventValueChanged];
    
    self.pulledToGetData = false;
    [self getData];
    

    
}

#pragma mark - Refresh

-(void)pulledRefresh {
    if (self.refreshControl) {
        self.pulledToGetData = true;
        [self.activityIndicator startAnimating];
        
        [self performSelector:@selector(getData) withObject:nil afterDelay:0.5];
    }
}

/**
 *  Get Data by using the mConnection Class
 */
-(void) getData {

    NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mioty.NR_Injector"];
    self.Address = ([myDefaults objectForKey:@"ip"]) ? [myDefaults objectForKey:@"ip"] : [myDefaults objectForKey:@"cloudURL"];
    self.cloudURL = [myDefaults objectForKey:@"cloudURL"];
    self.password = [myDefaults objectForKey:@"password"];
//    NSLog(@"viewDidLoad NSUserDefaults: %@",[myDefaults objectForKey:@"ip"]);
//    NSLog(@"viewDidLoad NSUserDefaults: %@",[myDefaults objectForKey:@"password"]);
    
    if (self.Address != nil) {
        _mConnect = [mConnection new];
        MainTableViewCTRL * __weak weakSelf = self;
        
        [_mConnect getNodesFromIP:self.Address
                      andPassword:self.password
                     withCallBack:^(bool error, NSMutableArray *response) {
                         if (!error) {
                             weakSelf.cellTitles = response;
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [weakSelf.tableView reloadData];
                             });
                             
                         } else {
                             weakSelf.cellTitles = response;
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [weakSelf.tableView reloadData];
                                 
                                 [[[UIAlertView alloc] initWithTitle:@"Sorry!"
                                                             message:@"There was an issue connecting, please try again."
                                                            delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                             });
                         }
                     }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Reminder!" message:@"Go to the settings and input a URL." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        
    }
    [self.refreshControl endRefreshing];
    [self.activityIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    if (self.cellTitles.count <= 0) {
        [self.tableView addSubview:backgroundMessage];
    } else {
        [backgroundMessage removeFromSuperview];
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_cellTitles count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    nrCell *cell = (nrCell *)[tableView dequeueReusableCellWithIdentifier:@"nrCell" forIndexPath:indexPath];
    
    NSDictionary *obj = [_cellTitles objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    cell.nrLabel.text = [obj objectForKey:@"name"];
    [cell setLeftUtilityButtons:[self leftButtons: UIColorFromRGB(appColor)] WithButtonWidth:320];
    cell.delegate = self;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //stuff
    //as last line:
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - SWTableViewDelegate

- (NSArray *)leftButtons:(UIColor *)bgColor{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    
    [leftUtilityButtons sw_addUtilityButtonWithColor: bgColor title:@""];
    
    return leftUtilityButtons;
}

- (void)swipeableTableViewCell:(nrCell *)cell scrollingToState:(SWCellState)state{
    switch (state) {
        case 1:
            [self triggerNodeAtIndex:[self.tableView indexPathForCell:cell]];
            [self performSelector:@selector(closeUtilityButtons:) withObject:cell];
            [self performSelector:@selector(flashAnimation:) withObject:cell];
            
            break;
        default:
            break;
    }
}

- (void)flashAnimation:(nrCell *)cell{
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
    [UIView animateWithDuration: 0.7
                     animations: ^{
                         flash.alpha = 0.0;
                     }
                     completion: ^(BOOL finished) {
                         [flash removeFromSuperview];
                     }
     ];
}

-(void)closeUtilityButtons:(nrCell *)cell {
    [cell hideUtilityButtonsAnimated:NO];
}

#pragma mark - Triggered Methods

-(void)triggerNodeAtIndex:(NSIndexPath *)nIndex {
    NSString *pid = [[self.cellTitles objectAtIndex:nIndex.row] objectForKey:@"id"];

    [_mConnect triggerNodeWithIP:self.Address
                     andPassword:self.password
                       andNodeID:pid withCallBack:^(bool error, NSMutableArray *response) {
                           NSLog(@"Triggered Node Response: %@",response);
                       }];
}

-(void)didDismissSecondViewController {
    NSLog(@"didDismissSecondViewController");
    [self getData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"settingSegue"]) {
        
        //Listen to when Modal is dismissed
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didDismissSecondViewController)
                                                     name:@"SecondViewControllerDismissed"
                                                   object:nil];
        
    }
}

@end
