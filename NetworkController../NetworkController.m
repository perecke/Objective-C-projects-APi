#import "NetworkControllerSendingRecievingData.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <netdb.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

@implementation NetworkControllerSendingRecievingData

//　Port setup
#define BUFSIZE 8//8192
#define TCP_PORT 30001 //30001
#define UDP_PORT 5000

// Port number and socket
int srcSocket;  // my
int dstSocket;  // partner

char serverip[100]="192.168.0.4";  //192.168.0.4 //192.168.0.7 // 10.0.1.13 database server IP //Perecke net IP: 192.168.43.106 //IP Iphone 172.20.10.3

char textdata[11]="01234567890";
char buf[BUFSIZE];
char juliBuff[BUFSIZE];

char statusBuf[BUFSIZE];


// sockaddr_in
struct sockaddr_in s_addr;
struct sockaddr_in c_addr;
socklen_t len;
unsigned long dst_ip;
int		port,n;

int initServer = 0;



//Initialize the server
int client_init(){ //not void
    
    //init the client
    if ((srcSocket = socket(AF_INET, SOCK_STREAM, 0)) < 0) {
        printf("Fail to Sensor Network Server\n");
    }
    else{
        memset((char *) &s_addr, 0, sizeof(s_addr));
        s_addr.sin_family      = AF_INET;
        s_addr.sin_addr.s_addr = inet_addr(serverip);
        s_addr.sin_port        = htons(TCP_PORT);
        if (connect(srcSocket, (struct sockaddr *) &s_addr, sizeof s_addr) < 0) {
            printf("NO Sensor Network Server\n");
            return 0; // If there is no server return 0
        }
    }
    
    return 1;
    
}


const char * returnRecievedMessageFromServer(){
    char rank[10];
    int num=0,point=0,p;
    //udp通信を用いたserverのIPの収得
    //    udpreceive();
    printf("Client Started \n");
    
    int loopThrough = 1;
    juliBuff[0]='\0';
    
    while (loopThrough == 1) {
        //Clientの初期化
        
        initServer = client_init();
        
        if (initServer == 0) {
            break;
        }
        
        num=1;
        rank[0]=textdata[num];
        
        //点数の分類
        point=87;
        p=point/100;
        rank[1]='\0';//textdata[p];
        p=(point%100)/10;
        rank[2]= '\0';//textdata[p];
        p=(point%10);
        rank[3]= '\0';//textdata[p];
        rank[4]='\0';
        
        //rankの値をbufに入れる
        memset(buf,0,sizeof(buf));
        strcpy(buf, rank);
        
        //sendを用いてデータを送信
        
        int ss = send(srcSocket, buf, sizeof(buf),0);
        if ((send(srcSocket, buf, sizeof(buf),0)) == -1) {
            printf("Sending number failed \n");
        }
        else{
            printf("Sending number: %s\n", buf);
        }
         
        
        //send(srcSocket, buf, sizeof(buf),0); //send
        
        //printf("sending message: %s\n", buf);
        //int rr = recv(srcSocket, juliBuff, sizeof(juliBuff), 0);
        if((recv(srcSocket, juliBuff, sizeof(juliBuff), 0)) == -1){ //srcSocket
            printf("Failed to recieve \n");
        }
        else{
            printf("Juli buffer is %s",juliBuff);
            printf("Recieve from server: %02x, %02x, %02x, %02x, %02x, %02x, %02x, %02x\n",
                   (unsigned char)juliBuff[0],(unsigned char)juliBuff[1]
                   , (unsigned char)juliBuff[2],(unsigned char)juliBuff[3]
                   , (unsigned char)juliBuff[4],(unsigned char)juliBuff[5]
                   , (unsigned char)juliBuff[6],(unsigned char)juliBuff[7]);
            loopThrough = 0;
        }
        
        //juliBuff[0]='\0';
        
        
        //receive from server
        //        recv(server_socket, robot2, sizeof(robot2),0); //recieve
        //        printf("Receive from Server : %s\n",robot2);
        sleep(1);
        //サーバを終了
        close(srcSocket);
        printf("Client Closed \n");
        //メモリ解放
        fflush(stdin);
    }
    
    return juliBuff;
}

//Send int number to the user after it decides where to go
int send_int(int num, int messageTypeNumber){
    int conv = htonl(num);
    char *data = malloc(sizeof(num) + 1);//toArray(num);//(char*)&conv;
    sprintf(data, "%d",num);
    int left = sizeof(conv);
    int rc;
    
    int isSuccess = 0;
    
    //snprintf(statusBuf, sizeof(statusBuf), "%d",num);
    memset(statusBuf, 0, sizeof(statusBuf));
    //strcpy(statusBuf, data);
    //printf("The sending data is %s",statusBuf);
    if (messageTypeNumber == 20) {
        statusBuf[3] = 0x02;
    }
    else{
        statusBuf[3] = 0x03;
    }
    
    num = num-messageTypeNumber;
    if (num == 1) statusBuf[7] = 0x01;
    else if (num == 2) statusBuf[7] = 0x02;
    else if (num == 3) statusBuf[7] = 0x03;
    else if (num == 4) statusBuf[7] = 0x04;
    else if (num == 5) statusBuf[7] = 0x05;
    
    do{
        isSuccess = client_init();
        if (isSuccess == 0) {
            printf("Failed to send message to server");
            break;
        }
        rc = send(srcSocket, statusBuf, sizeof(statusBuf),0); //data sizeof(conv)
        if (rc < 0) {
            if ((errno == EAGAIN) || (errno == EWOULDBLOCK)) {
                //something
            }
            else if(errno != EINTR){
                return -1;
            }
        }
        else{
            data += rc;
            left -= rc;
        }
    }while (left > 0);
    
    //printf("Sending message to server %i", num);
    
    printf("Sending to server: %02x, %02x, %02x, %02x, %02x, %02x, %02x, %02x\n",
           (unsigned char)statusBuf[0],(unsigned char)statusBuf[1]
           , (unsigned char)statusBuf[2],(unsigned char)statusBuf[3]
           , (unsigned char)statusBuf[4],(unsigned char)statusBuf[5]
           , (unsigned char)statusBuf[6],(unsigned char)statusBuf[7]);
    
    return 0;
}



@end
