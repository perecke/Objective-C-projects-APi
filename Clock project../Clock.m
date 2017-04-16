#import "ClockClass.h"
#import <UIKit/UIKit.h>

@implementation ClockClass

-(UIImage *)drawTheClock:(UIImage *)image :(UIColor *)color{
    
    UIGraphicsBeginImageContext(image.size);
    [image drawAtPoint:CGPointMake(0,0)];
    
    //Smal clock ticker thing
   
    int absoluteValue = _hour;
    int clockValue = 0;
    int elojel = 1;
    if (_hour > 12) {
        absoluteValue = (_hour - 12);
    }
    if (absoluteValue >= 3 && absoluteValue <= 12) { //hour hour
        //elojel = -1;
        clockValue = absoluteValue - 3;
    }
    
    if (absoluteValue < 3) { // hour
        clockValue = 3 - absoluteValue;
        elojel = -1;
    }
    CGContextRef cotext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(cotext);
    //int szorzo = absoluteValue / 2;
    double angle =(elojel * clockValue * 30) * (M_PI/180); //30
    //NSLog(@"The angel %d and cock is %i",angle,clockValue);
    
    if (_minute > 30) {
        angle += (elojel * 15) * (M_PI/180);
    }
    
    CGContextSetLineWidth(cotext, 10.0);
    //length = 80
    double endX = cos(angle) * 60 + image.size.width/2;
    double endY = sin(angle) * 60 + image.size.height / 2;
    CGContextMoveToPoint(cotext,endX,endY ); //(image.size.width/2), 60
    CGContextAddLineToPoint(cotext, image.size.width/2, image.size.height / 2);
    /////////////////////////
    
    //Bigger ticker
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
    
    double angleForMinute = (absoluteValeMinute * minuteElojel * 6) * (M_PI/180); //step is 6 degree
    double endxMinute = cos(angleForMinute) * 90 + image.size.width / 2;
    double endYMinute = sin(angleForMinute) * 90 + image.size.width / 2;
    
    CGContextMoveToPoint(cotext, endxMinute, endYMinute); //((image.size.width/2), 60
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
    
    double angleForSecond = (absoluteValueSeconds * secondElojel * 6) * (M_PI/180);
    double endXSecond = cos(angleForSecond) * 100 + image.size.width / 2;
    double endYSecond = sin(angleForSecond) * 100 + image.size.height / 2;
    CGContextMoveToPoint(cotext, endXSecond, endYSecond);
    CGContextAddLineToPoint(cotext, image.size.width/2, image.size.height/2);
    
    // CGContextConcatCTM(cotext, transform);
    CGContextStrokePath(cotext);
    //
    //Long clock ticcker thing
    //Creat the new image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
    //return nil;
}

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
