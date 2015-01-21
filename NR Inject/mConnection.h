//
//  mConnection.h
//  NR Inject
//
//  Created by Fabian Buentello on 1/20/15.
//  Copyright (c) 2015 Fabian Buentello. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface mConnection : NSObject {
    void (^_completionHandler)(bool error, NSMutableArray *response);
    void (^_getNodesHandler)(bool error, NSMutableArray *response);
    void (^_triggerHandler)(bool error, NSMutableArray *response);
    void (^_verifyHandler)(bool error, NSMutableArray *response);
}

- (void)getNodesFromIP:(NSString *)url
           andPassword:(NSString *)password
          withCallBack:(void(^)(bool error, NSMutableArray *response))nodeHandler;

- (void)triggerNodeWithIP:(NSString *)url
              andPassword:(NSString *)password
                andNodeID:(NSString *)nodeID
             withCallBack:(void(^)(bool error, NSMutableArray *response))triggerHandler;

- (void) verifyipAddress:(NSString *)ipAddress
            withPassword:(NSString *)password
            withCallBack:(void(^)(bool error, NSMutableArray *response))verifyHandler;
@end
