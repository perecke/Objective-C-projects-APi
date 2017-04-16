//
//  NetworkControllerSendingRecievingData.h
//  interfaceElderlySupport
//
//  Created by Kubota Naoyuki on 2017/02/24.
//  Copyright © 2017年 Kubota Naoyuki. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkControllerSendingRecievingData : NSObject

extern const char * returnRecievedMessageFromServer();
extern int send_int(int num, int messageTypeNumber);

extern int client_init();

@end
