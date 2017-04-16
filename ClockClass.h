//
//  ClockClass.h
//  interfaceElderlySupport
//
//  Created by Kubota Naoyuki on 2017/03/03.
//  Copyright © 2017年 Kubota Naoyuki. All rights reserved.
//

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
