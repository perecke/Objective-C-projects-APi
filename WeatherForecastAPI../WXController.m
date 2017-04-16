
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //First priority


#import "WXController.h"
#import "HourlyWeatherItem.h"

@implementation WXController


float userLatitude;
float userLongtitude;
double valueOneCelsiusInKelvin = 274.15;

NSString *cityName = @"Loading";
NSString *currentCondition = @"Clear";
NSString *currentTemperature = @"0°";
NSString *maxMinTemperature = @"0°/0°";
NSString *theIconName = @"weather-clear.png";


NSMutableArray *arrayOfTheHourlyForecast;

NSDateComponents *components;
NSCalendar *calendar;
int todaysData = 0; //0 means yes it is still today's data
NSInteger indexPatha2 = 0;


//load the viewDidLoad again because fetching the data is very slow
int loaded = 0;

-(id)init{
    if (self = [super init]) {
        _hourlyFormatter = [[NSDateFormatter alloc]init];
        [_hourlyFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EET"]];
        [_hourlyFormatter setLocale:[NSLocale currentLocale]];
        [_hourlyFormatter setDateFormat:@"yyyy-MM-dd H:mm:ss"];
        [_hourlyFormatter setFormatterBehavior:NSDateFormatterBehaviorDefault];
        
    }
    
    return  self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    //get the Location of the User
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    //store the forecast data
    arrayOfTheHourlyForecast = [[NSMutableArray alloc]init];
    //current date and hour
    components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour fromDate:[NSDate date]];
    //NSLog(@"The current date of today is %@",components);
    calendar  = [NSCalendar currentCalendar];
    
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 8.0) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    userLatitude = locationManager.location.coordinate.latitude;
    userLongtitude = locationManager.location.coordinate.longitude;
    
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=ef12dbbea654b57243673c86b64d026a",userLatitude,userLongtitude];
    NSString *urlStringForHourlyForecast = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&appid=ef12dbbea654b57243673c86b64d026a",userLatitude,userLongtitude];
    
    NSURL *urlOfCurrentCondition = [NSURL URLWithString:urlString];
    NSURL *urlOfHourlyForecast = [NSURL URLWithString:urlStringForHourlyForecast];
    
    if (loaded == 0) {
        dispatch_async(kBgQueue, ^{
            
            NSData *data = [NSData dataWithContentsOfURL:urlOfCurrentCondition];
            [self performSelectorOnMainThread:@selector(fetchData:) withObject:data waitUntilDone:YES];
            
            //hourly forecast
            NSData *dataHourly = [NSData dataWithContentsOfURL:urlOfHourlyForecast];
            [self performSelectorInBackground:@selector(fetchHourlyData:) withObject:dataHourly];
        });
    }
    //setting up the view itself
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    UIImage *background = [UIImage imageNamed:@"tokyoBack"];
    
    self.backgroundImageView = [[UIImageView alloc]initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.blurredImageView = [[UIImageView alloc]init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    //[self.blurredImageView setImage]
    [self.view addSubview:_blurredImageView];
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
    
    //set up layout frames and margins
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    CGFloat inset = 20;
    
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    
    CGRect hiloFrame = CGRectMake(inset,headerFrame.size.height - hiloHeight, headerFrame.size.width -(2 * inset), hiloHeight);
    CGRect tempreatureFrame = CGRectMake(inset, headerFrame.size.height - (temperatureHeight + hiloHeight), headerFrame.size.width - (2 * inset), temperatureHeight);
    CGRect iconFrame = CGRectMake(inset, tempreatureFrame.origin.y - iconHeight, iconHeight, iconHeight);
    
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
    
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
    UILabel *temperatureLabel = [[UILabel alloc]initWithFrame:tempreatureFrame];
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = currentTemperature;
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    [header addSubview:temperatureLabel];
    
    UILabel *hiloLabel = [[UILabel alloc]initWithFrame:hiloFrame];
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = maxMinTemperature;
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    [header addSubview:hiloLabel];
    
    UILabel *cityLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,20,self.view.bounds.size.width,30)];
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = cityName;
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    [header addSubview:cityLabel];
    
    UILabel *conditionsLabel = [[UILabel alloc]initWithFrame:conditionsFrame];
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.textColor = [UIColor whiteColor];
    conditionsLabel.text = currentCondition;
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    [header addSubview:conditionsLabel];
    
    UIImageView *iconVew = [[UIImageView alloc]initWithFrame:iconFrame];
    iconVew.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *myImage = [UIImage imageNamed:theIconName];
    iconVew.image = myImage;
    iconVew.backgroundColor = [UIColor clearColor];
    [header addSubview:iconVew];
    
    //end of setting up the view
}



-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

//fetch CURRENT weather data from open weather api
-(void)fetchData:(NSData *)responseData{
    NSError *error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    
    //get the current location (city Name)
    NSString *cityData = [json objectForKey:@"name"];
    cityName = cityData;
    NSLog(@"The name of the city is: %@",cityData);
    
    //get the condition of the weather
    NSArray *weatherData = [json objectForKey:@"weather"];
    NSDictionary *firstElementOfWeather = [weatherData objectAtIndex:0];
    NSDictionary *mainComponent = [firstElementOfWeather objectForKey:@"main"];
    NSArray *arrayOfTheMain = [NSArray arrayWithObjects:mainComponent, nil];
    NSString *mainCondition = [arrayOfTheMain objectAtIndex:0];
    currentCondition = mainCondition;
    NSLog(@"Current weather condition is %@",mainCondition);
    //get the icon
    NSDictionary *iconComponent = [firstElementOfWeather objectForKey:@"icon"];
    NSArray *arrayOfTheIcon = [NSArray arrayWithObjects:iconComponent, nil];
    NSString *weatherIcon = [arrayOfTheIcon objectAtIndex:0];
    theIconName = [self imageName:weatherIcon];
    NSLog(@" \n The Icon of the weather is %@",weatherIcon);
    
    //get the temperature of the weather and convert it to Celsius
    NSDictionary *mainDic = [json objectForKey:@"main"];
    NSDictionary *tempDic = [mainDic objectForKey:@"temp"];
    NSArray *arrayForTemp = [NSArray arrayWithObjects:tempDic, nil];
    NSNumber *tempNumer = [arrayForTemp objectAtIndex:0];
    double temperatureKelvin = [tempNumer doubleValue];// in the JSON the value of the temperature is in Kelvin
    double temperatureInCelsiu = round(temperatureKelvin - valueOneCelsiusInKelvin);
    currentTemperature = [NSString stringWithFormat:@"%i°",(int)temperatureInCelsiu];
    NSLog(@"The tempreature in celsius is %i",(int)temperatureInCelsiu);
    
    //max and minimum temperature
    int maxTemperature = [self returnMaxTemperature:json];
    int minTemperature = [self returnMinTemperature:json];
    maxMinTemperature = [NSString stringWithFormat:@"%i°/%i°",minTemperature,maxTemperature];
    
    //get the iconName
    
    
    loaded = 1;
    
    [self viewDidLoad];
}

-(void)fetchHourlyData:(NSData *)responseData{
    NSError *error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    NSLog(@"Fetched the hourly data bitch!!!!");
    int minTemp = 0;
    int maxTemp = 0;
    
    if ([json isKindOfClass:[NSDictionary class]]) {
        NSArray *myWeatherDictionaryArray = json[@"list"];
        if ([myWeatherDictionaryArray isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dictionary in myWeatherDictionaryArray) {
                
                if (todaysData == 0) {
                    HourlyWeatherItem *item = [[HourlyWeatherItem alloc]init];
                    
                    //get the condition of the weather
                    NSArray *descriptionArray = [dictionary objectForKey:@"weather"];
                    NSDictionary *firstElementOfWeather = [descriptionArray objectAtIndex:0];
                    NSDictionary *mainComponent = [firstElementOfWeather objectForKey:@"main"];
                    NSArray *arrayOfTheMain = [NSArray arrayWithObjects:mainComponent, nil];
                    NSString *mainCondition = [arrayOfTheMain objectAtIndex:0];
                    item.condition = mainCondition;
                    
                    //get the min/max temperature of the weather
                    minTemp = [self returnMinTemperature:dictionary];
                    maxTemp = [self returnMaxTemperature:dictionary];
                    item.minTemp = minTemp;
                    item.maxTemp = maxTemp;
                    
                    //fetch the icon name
                    item.iconName = [self getTheIconNameOfTheItem:dictionary];
                    
                    //fetch the time
                    item.date = [self getTheDate:dictionary];
                    
                    [arrayOfTheHourlyForecast addObject:item];
                }
                
            }
        }
    }
    
    NSLog(@"Items has been added sucesfully %lu",(unsigned long)[arrayOfTheHourlyForecast count]);
}

//getting the max temperature
-(int)returnMaxTemperature:(NSDictionary *) json{
    
    NSDictionary *mainDic = [json objectForKey:@"main"];
    NSDictionary *tempDic = [mainDic objectForKey:@"temp_max"];
    NSArray *arrayForTemp = [NSArray arrayWithObjects:tempDic, nil];
    NSNumber *tempNumer = [arrayForTemp objectAtIndex:0];
    double temperatureKelvin = [tempNumer doubleValue];// in the JSON the value of the temperature is in Kelvin
    double temperatureInCelsiu = round(temperatureKelvin - valueOneCelsiusInKelvin);
    //currentTemperature = [NSString stringWithFormat:@"%i°",(int)temperatureInCelsiu];
    //NSLog(@"The max tempreature in celsius is %i",(int)temperatureInCelsiu);
    
    return (int)temperatureInCelsiu;
}

//getting the min temperature
-(int)returnMinTemperature:(NSDictionary *)json{
    NSDictionary *mainDic = [json objectForKey:@"main"];
    NSDictionary *tempDic = [mainDic objectForKey:@"temp_min"];
    NSArray *arrayForTemp = [NSArray arrayWithObjects:tempDic, nil];
    NSNumber *tempNumer = [arrayForTemp objectAtIndex:0];
    double temperatureKelvin = [tempNumer doubleValue];// in the JSON the value of the temperature is in Kelvin
    double temperatureInCelsiu = round(temperatureKelvin - valueOneCelsiusInKelvin);
    //currentTemperature = [NSString stringWithFormat:@"%i°",(int)temperatureInCelsiu];
   // NSLog(@"The min tempreature in celsius is %i",(int)temperatureInCelsiu);
    
    return (int)temperatureInCelsiu;
}

//get the icon name of the item TODO get all of the items from a function
-(NSString *)getTheIconNameOfTheItem:(NSDictionary *)json{
    NSArray *descriptionArray = [json objectForKey:@"weather"];
    NSDictionary *firstElementOfWeather = [descriptionArray objectAtIndex:0];
    NSDictionary *mainComponent = [firstElementOfWeather objectForKey:@"icon"];
    NSArray *arrayOfTheMain = [NSArray arrayWithObjects:mainComponent, nil];
    NSString *mainIcon = [arrayOfTheMain objectAtIndex:0];
    NSString *realIconName = [self imageName:mainIcon];
    
    return [NSString stringWithFormat:@"%@",realIconName];
}

-(NSDate *)getTheDate:(NSDictionary *)json{
   // NSNumber *dateNumber = [json objectForKey:@"dt"];
    
    NSString *dateInString = [json objectForKey:@"dt_txt"];
    NSLog(@"Date string: %@",dateInString);
    NSDate *date = [_hourlyFormatter dateFromString:dateInString];
    NSLog(@"Date %@",date);
    //NSDateComponents *currentDateItem = [[NSCalendar currentCalendar]components:NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];

    return date;
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2; // five hourly forecast
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 15;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    //TODO set up cell
    
    if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                [self configureHeaderCell:cell title:@"Hourly forecast"];
            }
            else{
                HourlyWeatherItem *currentItem = [arrayOfTheHourlyForecast objectAtIndex:indexPath.row];
            
                [self configureHourlyCell:cell weatherForecastObject:currentItem];
                
            }
    }
    
    if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                [self configureHeaderCell:cell title:@"Later forecast"];
            }
            else{
                HourlyWeatherItem *currentItemSectionB = [arrayOfTheHourlyForecast objectAtIndex:indexPatha2 + 1];
                [self configureHourlyCell:cell weatherForecastObject:currentItemSectionB];
                
            }
    }
    
    return cell;
}

//configure header cell
-(void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

- (void)configureHourlyCell:(UITableViewCell *)cell weatherForecastObject:(HourlyWeatherItem *)item {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    
    NSDate *actualDate = [item date];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:actualDate];
    NSInteger hourJ = [components hour];
    cell.textLabel.text = [NSString stringWithFormat:@"%li:00",(long)hourJ];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i / %i°",[item minTemp],[item maxTemp]];
    NSString *nameOfTheIcon = [item iconName];
    //NSLog(@"Name of the icon is:%@",nameOfTheIcon);
    cell.imageView.image = [UIImage imageNamed:nameOfTheIcon];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}


#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
    return 44;
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

//icon pictures
-(NSDictionary *)imageMap {
    // 1
    static NSDictionary *_imageMap = nil;
    if (! _imageMap) {
        // 2
        _imageMap = @{
                      @"01d" : @"weather-clear",
                      @"02d" : @"weather-few",
                      @"03d" : @"weather-few",
                      @"04d" : @"weather-broken",
                      @"09d" : @"weather-shower",
                      @"10d" : @"weather-rain",
                      @"11d" : @"weather-tstorm",
                      @"13d" : @"weather-snow",
                      @"50d" : @"weather-mist",
                      @"01n" : @"weather-moon",
                      @"02n" : @"weather-few-night",
                      @"03n" : @"weather-few-night",
                      @"04n" : @"weather-broken",
                      @"09n" : @"weather-shower",
                      @"10n" : @"weather-rain-night",
                      @"11n" : @"weather-tstorm",
                      @"13n" : @"weather-snow",
                      @"50n" : @"weather-mist",
                      };
    }
    return _imageMap;
}

//get backTheImage path
-(NSString *)imageName:(NSString *)iconName{
    
    NSDictionary *dic = [self imageMap];
    
    NSString *imageName = (NSString*)[dic objectForKey:iconName];
    
    return [NSString stringWithFormat:@"%@.png",imageName];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    // 2
    CGFloat percent = MIN(position / height, 1.0);
    // 3
    self.blurredImageView.alpha = percent;
    
    
}


@end
