
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ClockClass : NSObject

@property (nonatomic) int hour;
@property (nonatomic) int minute;
@property (nonatomic) int second;

//Functions
-(UIImage *)drawTheClock:(UIImage *)image :(UIColor *)color;
-(void)updateTime;


@end
