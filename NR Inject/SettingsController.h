//
//  SettingsController.h
//  NR Inject
//
//  Created by Fabian Buentello on 1/20/15.
//  Copyright (c) 2015 Fabian Buentello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "mConnection.h"
@class TPKeyboardAvoidingScrollView;
@interface SettingsController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *ipAddress;
@property (strong, nonatomic) IBOutlet UITextField *port;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property(strong, nonatomic) IBOutlet UILabel *checkMarkLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loadSpinner;
@property (strong, nonatomic) NSString *ipAddressStr;
@property (strong, nonatomic) NSString *passwordStr;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;

@end
