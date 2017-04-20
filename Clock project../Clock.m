#import "ClockClass.h"
#import <UIKit/UIKit.h>

@implementation ClockClass

-(UIImage *)drawTheClock:(UIImage *)image :(UIColor *)color{
    
    UIGraphicsBeginImageContext(image.size);
    [image drawAtPoint:CGPointMake(0,0)];
    
    //Hour ticker
   
    int absoluteValue = _hour;
    int clockValue = 0;
    int elojel = 1;
    if (_hour > 12) {
        absoluteValue = (_hour - 12);
    }
    //Check if we are between 3 and 12 because of the degree calculation
    if (absoluteValue >= 3 && absoluteValue <= 12) { 
        clockValue = absoluteValue - 3;
    }
    
    if (absoluteValue < 3) { // hour
        clockValue = 3 - absoluteValue;
        elojel = -1;
    }
    CGContextRef cotext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(cotext);
    //We are going to move the hour ticker 30 degree every time an hour has passed by
    double angle =(elojel * clockValue * 30) * (M_PI/180); //30
    
    //If it is past 30 secoond, we moce the hour ticker to make the clock more easy to understand
    if (_minute > 30) {
        angle += (elojel * 15) * (M_PI/180);
    }
    
    CGContextSetLineWidth(cotext, 10.0);
    //Calculate the angle of the ticker where the length is 60 pixel and the image is the clock`s main image
    double endX = cos(angle) * 60 + image.size.width/2;
    double endY = sin(angle) * 60 + image.size.height / 2;
    CGContextMoveToPoint(cotext,endX,endY ); 
    CGContextAddLineToPoint(cotext, image.size.width/2, image.size.height / 2);
    /////////////////////////
    
    //Minute ticker
    int absoluteValeMinute = _minute; //minuteValue
    int minuteElojel = 1;
    
    if (absoluteValeMinute > 15) {
        absoluteValeMinute = (15 - _minute); //minutevalue
        minuteElojel = -1;
    }
    else{
        absoluteValeMinute = _minute - 15; //minutevalue
        minuteElojel = 1;
    }
    
    //We move the minute ticker by 6 degree every time a minte is passed
    double angleForMinute = (absoluteValeMinute * minuteElojel * 6) * (M_PI/180); //step is 6 degree
    
    //Calculate the right angle of the minute ticker, and its length will be 90 pixels
    double endxMinute = cos(angleForMinute) * 90 + image.size.width / 2;
    double endYMinute = sin(angleForMinute) * 90 + image.size.width / 2;
    
    CGContextMoveToPoint(cotext, endxMinute, endYMinute); 
    CGContextAddLineToPoint(cotext, image.size.width/2, image.size.height / 2);
    CGContextSetStrokeColorWithColor(cotext, [color CGColor]);
    /////////////////////////
    
    //Seconds ticker
    int absoluteValueSeconds = _second;
    int secondElojel = 1;
    
    if (absoluteValueSeconds > 15) {
        absoluteValueSeconds = (15 - _second);
        secondElojel = -1;
    }
    else{
        absoluteValueSeconds = _second - 15;
        secondElojel = 1;
    }
    
    //Move the second ticker by 6 degree
    double angleForSecond = (absoluteValueSeconds * secondElojel * 6) * (M_PI/180);
    
    //Make it 100 pixel long, so we can see size difference beside moving difference
    double endXSecond = cos(angleForSecond) * 100 + image.size.width / 2;
    double endYSecond = sin(angleForSecond) * 100 + image.size.height / 2;
    CGContextMoveToPoint(cotext, endXSecond, endYSecond);
    CGContextAddLineToPoint(cotext, image.size.width/2, image.size.height/2);
    
    CGContextStrokePath(cotext);
    //Creat the new image and we draw the context we just created on the image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
    //return nil;
}

//This function gets the system time and updates the hour/minute/second values when we draw the clock
-(void)updateTime{
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:now];
    //NSLog(@"newDateString %@", newDateString);
    NSArray* array = [newDateString componentsSeparatedByString:@":"];
    for (int i = 0; i < array.count; i++) {
        //NSLog(@"%@",array[i]);
    }
    
    _hour = [array[0] intValue];
    _minute =[array[1] intValue];
    _second = [array[2] intValue];
}



@end
