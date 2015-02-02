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

@implementation SettingsController
@synthesize ipAddress,password,port,loadSpinner,ipAddressStr,passwordStr;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mioty.NR_Injector"];
    
    NSLog(@"viewDidLoad NSUserDefaults: %@",[myDefaults objectForKey:@"ip"]);
    NSLog(@"viewDidLoad NSUserDefaults: %@",[myDefaults objectForKey:@"password"]);
    
    self.ipAddressStr = [myDefaults objectForKey:@"ip"];
    self.passwordStr = [myDefaults objectForKey:@"password"];
    
    _mConnect = [mConnection new];
    self.checkMarkLabel.text = [NSString fontAwesomeIconStringForEnum:FACheck];
    self.checkMarkLabel.hidden = YES;
    
    
    self.ipAddress.delegate = self;
    self.port.delegate = self;
    self.password.delegate = self;
    
    if (self.ipAddressStr && self.passwordStr) {
        NSArray *urlArray = [self.ipAddressStr componentsSeparatedByString:@":"];
        
        ipAddress.text = [urlArray objectAtIndex:0];
        port.text = [urlArray objectAtIndex:1];
        password.text = self.passwordStr;
    }
}

-(IBAction)verifyInfo:(id)sender {
    
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
                    [self performSelector:@selector(saveSettings) withObject:nil afterDelay:0.5];
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
- (void)saveSettings {
    
    [loadSpinner stopAnimating];
    
    // Helpers
    NSString *ipAdr = self.ipAddress.text;
    NSString *ipPort = self.port.text;
    NSString *pwd = self.password.text;
    
    //Save
    if ((ipAdr && pwd && ipPort) && (ipAdr.length && pwd.length && ipPort.length)) {
        
        // update Record
        self.ipAddressStr = [NSString stringWithFormat:@"%@:%@",ipAdr,ipPort];
        self.passwordStr = pwd;
        // Save Record
        NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.mioty.NR_Injector"];
        [myDefaults setObject:self.ipAddressStr forKey:@"ip"];
        [myDefaults setObject:self.passwordStr forKey:@"password"];
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
