//
//  SettingsController.m
//  NR Inject
//
//  Created by Fabian Buentello on 1/20/15.
//  Copyright (c) 2015 Fabian Buentello. All rights reserved.
//

#import "SettingsController.h"
#import "Config.h"
#import "mConnection.h"
#import "NSString+FontAwesome.h"

//mConnection
mConnection *_mConnect;

@implementation SettingsController {
    NSString *ipAddressStr;
    NSString *passwordStr;
    NSString *cloudURL;
    NSUserDefaults *myDefaults;
    bool isSetToURL;
}
@synthesize ipAddress,password,port,loadSpinner,urlSegmentedCtrl,cloudURLNote;

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    isSetToURL = false;
    if (cloudURL.length) {
        [self.urlSegmentedCtrl setSelectedSegmentIndex:1];
        [self segmentedControlChanged];
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];

    myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mioty.NR_Injector"];

    NSLog(@"viewDidLoad NSUserDefaults: %@",[myDefaults objectForKey:@"ip"]);
    NSLog(@"viewDidLoad NSUserDefaults: %@",[myDefaults objectForKey:@"password"]);



    _mConnect = [mConnection new];
    self.checkMarkLabel.text = [NSString fontAwesomeIconStringForEnum:FACheck];
    self.checkMarkLabel.hidden = YES;

    [self.urlSegmentedCtrl addTarget:self
                              action:@selector(segmentedControlChanged)
               forControlEvents:UIControlEventValueChanged];

    self.ipAddress.delegate = self;
    self.port.delegate = self;
    self.password.delegate = self;
    myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mioty.NR_Injector"];
    ipAddressStr = [myDefaults objectForKey:@"ip"];
    passwordStr = [myDefaults objectForKey:@"password"];
    cloudURL = [myDefaults objectForKey:@"cloudURL"];
    
    if (ipAddressStr.length && passwordStr.length) {
        NSArray *urlArray = [ipAddressStr componentsSeparatedByString:@":"];
        ipAddress.text = [urlArray objectAtIndex:0];
        port.text = [urlArray objectAtIndex:1];
    }
    password.text = passwordStr;
}

-(void)segmentedControlChanged {
    NSInteger selectedSegment = self.urlSegmentedCtrl.selectedSegmentIndex;


    switch (selectedSegment) {
        case 0:
            isSetToURL = false;
            self.ipAddress.hidden = false;
            self.cloudURLNote.hidden = true;
            self.port.placeholder = @"Port";
            port.text = (ipAddressStr.length && passwordStr.length) ? [[ipAddressStr componentsSeparatedByString:@":"] objectAtIndex:1] : @"";
            break;
        case 1:
            isSetToURL = true;
            self.cloudURLNote.hidden = false;
            self.ipAddress.hidden = true;
            self.port.placeholder = @"Cloud URL";
            self.port.text = cloudURL;
            break;

        default:
            break;
    }
    NSLog(@"valueChanged %ld", (long)selectedSegment);
}
-(IBAction)verifyInfo:(id)sender {

    if (!isSetToURL) {
        [self verifyInfoWithIPAddress];
    } else {
        [self verifyInfoWithCloudURL];
    }
}

/*
 User selected the Local tab on the SegmentedController
 */
-(void) verifyInfoWithIPAddress {
    if ((self.ipAddress.text && self.password.text) && (self.ipAddress.text.length && self.password.text.length)) {
        [loadSpinner startAnimating];
        NSString *urlStr = [NSString stringWithFormat:@"%@:%@",self.ipAddress.text,self.port.text];
        [_mConnect getNodesFromIP:urlStr andPassword:self.password.text withCallBack:^(bool error, NSMutableArray *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [loadSpinner stopAnimating];
                    // Show Alert View
                    [[[UIAlertView alloc] initWithTitle:@"Invalid Connection" message:@"Double check all fields and make sure Node-Red is running." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                } else {
                    [self performSelector:@selector(saveIPSettings) withObject:nil afterDelay:0.5];
                }
            });
        }];
    } else {
        // Show Alert View
        [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"URL and Password are required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}




/*
 User selected the URL tab on the SegmentedController
 */
-(void) verifyInfoWithCloudURL {
    if ((self.port.text && self.password.text) && (self.port.text.length && self.password.text.length)) {
        [loadSpinner startAnimating];
        NSString *urlStr = self.port.text;
        [_mConnect getNodesFromIP:urlStr andPassword:self.password.text withCallBack:^(bool error, NSMutableArray *response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [loadSpinner stopAnimating];
                    // Show Alert View
                    [[[UIAlertView alloc] initWithTitle:@"Invalid Connection" message:@"Double check all fields and make sure Node-Red is running." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                } else {
                    [self performSelector:@selector(saveCloudSettings) withObject:nil afterDelay:0.5];
                }
            });
        }];
    } else {
        // Show Alert View
        [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"URL and Password are required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

/**
 *  If we are here, that means all tests were passed and we are going to
 *  save the IP Adress and Password to the device
 */
- (void)saveIPSettings {

    [loadSpinner stopAnimating];

    // Helpers
    NSString *ipAdr = self.ipAddress.text;
    NSString *ipPort = self.port.text;
    NSString *pwd = self.password.text;

    //Save
    if ((ipAdr && pwd && ipPort) && (ipAdr.length && pwd.length && ipPort.length)) {

        // update Record
        ipAddressStr = [NSString stringWithFormat:@"%@:%@",ipAdr,ipPort];
        passwordStr = pwd;
        // Save Record
        myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mioty.NR_Injector"];
        [myDefaults setObject:ipAddressStr forKey:@"ip"];
        [myDefaults setObject:pwd forKey:@"password"];
        [myDefaults setObject:nil forKey:@"cloudURL"];
        if ([myDefaults synchronize]) {
            // Dismiss View Controller
            self.checkMarkLabel.hidden = NO;
            [self performSelector:@selector(dismissModalView:) withObject:self afterDelay:1.0];
            NSLog(@"IT SAVED!!!");

        } else {

            // Show Alert View
            [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"There was an issue saving, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }

    } else {
        // Show Alert View
        [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"URL and Password are required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}
- (void)saveCloudSettings {
    
    [loadSpinner stopAnimating];
    
    // Helpers
    NSString *cldURL = self.port.text;
    NSString *pwd = self.password.text;
    
    //Save
    if ((cldURL && pwd) && (cldURL.length && pwd.length)) {
        
        // Save Record
        myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mioty.NR_Injector"];
        [myDefaults setObject:nil forKey:@"ip"];
        [myDefaults setObject:pwd forKey:@"password"];
        [myDefaults setObject:cldURL forKey:@"cloudURL"];
        if ([myDefaults synchronize]) {
            // Dismiss View Controller
            self.checkMarkLabel.hidden = NO;
            [self performSelector:@selector(dismissModalView:) withObject:self afterDelay:1.0];
            NSLog(@"IT SAVED!!!");
            
        } else {
            
            // Show Alert View
            [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"There was an issue saving, please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
    } else {
        // Show Alert View
        [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"URL and Password are required." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}
- (IBAction)dismissModalView:(id)sender {
    //This sends a message through the NSNotificationCenter to any listeners for "SecondViewControllerDismissed"
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SecondViewControllerDismissed"
                                                        object:nil
                                                      userInfo:nil];

    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField {

    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}



@end
