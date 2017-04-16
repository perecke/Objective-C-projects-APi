# Objective-C-projects-APi
Objective-C APIs

CLOCK folder:
If you want to implement the class to your project. Copy the .m and the .h file to the project.
Set up an NSTimer to be called in every 0.5 seconds. Create an ImageView where you will draw the clock, and create an empty Image 
to invalidate it without drawing the previous clock image.

-(void)onTickForClock:(NSTimer *)timer{
    [_clockInstance updateTime]; // call this function to update time
    UIImage *newImage = [_clockInstance drawTheClock:_origImageClockPic :_colorGrey]; //orig image is an empty image to redraw the clock every time
    [_imageViewClock setImage:newImage];
}

NETWORKCONTROLLER folder:

The main.c class is a c class to set up the server we are going to use which ricives data and sends data from a buffer.

NetworkController.m/h simply copy it to your project, to the IP address set the IP address of the computer where you use the server and the port number too
The client will send the number 1 to the server to see of it is properly connected. You can send and recieve data by the client.

WEATHERFORECAST folder:

Copy the 2 classes and do the following in the main view. Make sure to copy the Images folder to your program so you can see the icons and the background picture

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


