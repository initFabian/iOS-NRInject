//
//  mConnection.m
//  NR Inject
//
//  Created by Fabian Buentello on 1/20/15.
//  Copyright (c) 2015 Fabian Buentello. All rights reserved.
//

#import "mConnection.h"

//NETWORKING
NSURLSession *session;
NSURLSessionDataTask *dataTask;

@implementation mConnection


/**
 *  This is where all the Networking happens.
 *
 *  @param session NSURLSession: mySessionWithPassword:
 *  @param req     NSMutableURLRequest: myRequestWithURL:
 *  @param handler Function: Callback
 */
- (void)dataTaskFromSession:(NSURLSession *)session andRequest:(NSMutableURLRequest *)req withCallBack:(void(^)(bool error, NSMutableArray *response))handler{
    
    _completionHandler = [handler copy];
    
    dataTask = [session
                dataTaskWithRequest:req
                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                    
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    
                    if (!error && ((long)[httpResponse statusCode] == 200)) {
                        
                        NSMutableArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        
                        _completionHandler(false, json);
                        
                    } else {
                        _completionHandler(true, nil);
                    }
                    
                    return ;
                }];
    [dataTask resume];
}


/**
 *  Sets the NSURLSession that will be passed to dataTaskFromSession:andRequest:withCallBack:
 *
 *  @param pwd String: Password for the config node
 *
 *  @return NSURLSession Object
 */

- (NSURLSession *)mySessionWithPassword:(NSString *)pwd {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{@"AUTH": pwd};
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    return session;
}


/**
 *  Sets NSMutableURLRequest that will be passed to dataTaskFromSession:andRequest:withCallBack:
 *
 *  @param url String: IP Address of Node-Red instance
 *
 *  @return NSMutableURLRequest Object
 */
- (NSMutableURLRequest *)myRequestWithURL:(NSString *)url {
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    return req;
}

- (void)getNodesFromIP:(NSString *)url
           andPassword:(NSString *)password
          withCallBack:(void(^)(bool error, NSMutableArray *response))nodeHandler{
    
    _getNodesHandler = [nodeHandler copy];
    NSURLSession *session = [self mySessionWithPassword:password];
    NSMutableURLRequest *request = [self myRequestWithURL:[NSString stringWithFormat:@"http://%@/injector/nodes",url]];
    
    [self dataTaskFromSession:session andRequest:request withCallBack:^(bool error, NSMutableArray *response) {
        _getNodesHandler(error, response);
    }];
}

- (void)triggerNodeWithIP:(NSString *)url
              andPassword:(NSString *)password
                andNodeID:(NSString *)nodeID
             withCallBack:(void(^)(bool error, NSMutableArray *response))triggerHandler{
    
    _triggerHandler = [triggerHandler copy];
    NSURLSession *session = [self mySessionWithPassword:password];
    NSLog(@"%@",[NSString stringWithFormat:@"%@/injector/inject?id=%@",url,nodeID]);
    NSMutableURLRequest *request = [self myRequestWithURL:[NSString stringWithFormat:@"http://%@/injector/inject?id=%@",url,nodeID]];
    
    [self dataTaskFromSession:session andRequest:request withCallBack:^(bool error, NSMutableArray *response) {
        _triggerHandler(error, response);
    }];
    
}

-(void)verifyipAddress:(NSString *)ipAddress
          withPassword:(NSString *)password
          withCallBack:(void (^)(bool error, NSMutableArray *response))verifyHandler{
    _verifyHandler = [verifyHandler copy];
    NSURLSession *session = [self mySessionWithPassword:password];
    NSMutableURLRequest *request = [self myRequestWithURL:[NSString stringWithFormat:@"http://%@/injector/status",ipAddress]];
    
    [self dataTaskFromSession:session andRequest:request withCallBack:^(bool error, NSMutableArray *response) {
        _verifyHandler(error, response);
    }];
}

@end
