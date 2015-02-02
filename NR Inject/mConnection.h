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

/**
 *  Get Nodes from Node-Red instance
 *
 *  @param url         String: IP Address of Node-Red instance
 *  @param password    String: Password for the config node
 *  @param nodeHandler Function: Callback
 */
- (void)getNodesFromIP:(NSString *)url
           andPassword:(NSString *)password
          withCallBack:(void(^)(bool error, NSMutableArray *response))nodeHandler;

/**
 *  Trigger Node
 *
 *  @param url            String: IP Address of Node-Red instance
 *  @param password       String: Password for the config node
 *  @param nodeID         String: nodeID
 *  @param triggerHandler Function: Callback
 */
- (void)triggerNodeWithIP:(NSString *)url
              andPassword:(NSString *)password
                andNodeID:(NSString *)nodeID
             withCallBack:(void(^)(bool error, NSMutableArray *response))triggerHandler;



/**
 *  Verify The IP Address before saving it
 *
 *  @param ipAddress     String: IP Address of Node-Red instance
 *  @param password      String: Password for the config node
 *  @param verifyHandler Function: Callback
 */
- (void) verifyipAddress:(NSString *)ipAddress
            withPassword:(NSString *)password
            withCallBack:(void(^)(bool error, NSMutableArray *response))verifyHandler;
@end
