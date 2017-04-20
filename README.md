# Objective-C-projects-APi
Objective-C APIs

CLOCK folder:
If you want to implement the class to your project. Copy the .m and the .h file to the project.
Set up an NSTimer to be called in every 0.5 seconds. Create an ImageView where you will draw the clock, and create an empty Image 
to invalidate it without drawing the previous clock image.

```
//Code for NSTimer where you want to set up the working clock
-(void)onTickForClock:(NSTimer *)timer{
    [_clockInstance updateTime]; // call this function to update time
     //orig image is an empty image to redraw the clock every time
    UIImage *newImage = [_clockInstance drawTheClock:_origImageClockPic :_colorGrey];
    _imageViewClock setImage:newImage]; 
}
```

NETWORKCONTROLLER folder:

The main.c class is a c class to set up the server we are going to use which ricives data and sends data from a buffer.
To start the server on your mac, open XCode, insert the server to a new C project and press play. The server will keep sending a buffer which can be string. 

NetworkController.m/h
1) Simply copy the NetWorkController.h/m to your project
2) To the IP address variable set the IP address of the computer where you use the server
The client will send the number 1 to the server to see of it is properly connected. You can send and recieve data by the client and calling the right functions. 

WEATHERFORECAST folder:

Copy the 2 classes and do the following steps in the main view. 
!!!!Make sure to copy the Images folder to your program so you can see the icons and the background picture.!!!!!
Add the following code to the mainView. 
To make the code work, you need to set up your OpenweatherMapAPI APIkey and copy it to the [YOURAPIID] fields. 

```
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define kLatestKivaLoansURL2 [NSURL URLWithString:@"http://api.openweathermap.org/data/2.5/forecast?lat=35.661640&lon=139.367282&appid=YOURAPIID"] //2

#import "ViewController.h"

@interface ViewController ()

@property(nonatomic,strong)NSMutableDictionary *dd;

@end

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   
    dispatch_async(kBgQueue, ^{
        NSData *data = [NSData dataWithContentsOfURL:kLatestKivaLoansURL2];
        [self performSelectorOnMainThread:@selector(fetchData:) withObject:data waitUntilDone:YES];
    });
}

-(void)fetchData:(NSData *)responseData{
    NSError *error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
   
    NSArray* list = [json objectForKey:@"list"];
    NSDictionary *firstElement = [list objectAtIndex:0];
    NSDictionary *windComponents = [firstElement objectForKey:@"wind"];
    NSDictionary *speedComponent = [windComponents objectForKey:@"speed"];
    NSArray *theArray = [NSArray arrayWithObjects:speedComponent, nil];
    NSString *hh = [theArray objectAtIndex:0];
   
    NSLog(@"The speed of the wind is %@",hh);
}

```


