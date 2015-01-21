//
//  Config.h
//  NR Inject
//
//  Created by Fabian Buentello on 1/20/15.
//  Copyright (c) 2015 Fabian Buentello. All rights reserved.
//

#ifndef NR_Inject_Config_h
#define NR_Inject_Config_h

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]    //hex converter

//#define appColor 0xff9900       //CHANGE COLOR OF APP IF NEEDED
#define appColor 0x7676BC       //CHANGE COLOR OF APP IF NEEDED

#define dummyJSON @"http://www.json-generator.com/api/json/get/cdAMWfAQHS?indent=4"

// get Nodes Format     :IPAddress:Port/injector/nodes              NSString *urlStr = [NSString stringWithFormat:@"%@/injector/nodes",self.currentSettings.url];
// Trigger Node Format  :IPAddress:Port/injector/inject?id=1234     NSString *TriggerStr = [NSString stringWithFormat:@"%@/injector/inject?id=%@",[obj objectForKey:@"id"]];


#endif
