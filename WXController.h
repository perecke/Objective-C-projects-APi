//
//  WXController.h
//  FetchingWeatherData
//
//  Created by Kubota Naoyuki on 2016/05/27.
//  Copyright © 2016年 Kubota Naoyuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface WXController : UIViewController <UITableViewDataSource, UITextViewDelegate,UIScrollViewDelegate, CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLLocationCoordinate2D *userLocation;
}

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat screenHeight;

@property (nonatomic,strong)NSDateFormatter *hourlyFormatter;

@end
