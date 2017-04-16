
#import <Foundation/Foundation.h>

@interface NetworkControllerSendingRecievingData : NSObject

extern const char * returnRecievedMessageFromServer();
extern int send_int(int num, int messageTypeNumber);

extern int client_init();

@end
