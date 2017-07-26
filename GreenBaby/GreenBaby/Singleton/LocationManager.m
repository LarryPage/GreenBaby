//
//  LocationManager.m
//  CardBump
//
//  Created by 香成 李 on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager ()<CLLocationManagerDelegate,UIAlertViewDelegate>{
    CLLocationManager *_locationManager;
    
    //CLGeocoder可正反解析，ios5以上
    CLGeocoder *_geoCoder;
    CLPlacemark *_placemark;
    NSInteger _geoCount;//尝试解析3次
}

@end

@implementation LocationManager

SINGLETON_IMP(LocationManager)

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _locationManager = [[CLLocationManager alloc] init];
        //_geoCoder = [[CLGeocoder alloc] init];
		_placemark = nil;
        _geoCount=0;
        
		_isLocationOk = NO;
        _locationFaked = NO;
        _coord.longitude = 0.0;
        _coord.latitude = 0.0;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self stop];
    if (_locationManager != nil){
        _locationManager = nil;
    }
    if (_geoCoder) {
        [_geoCoder cancelGeocode];
        _geoCoder = nil;
    }
}

- (void)start {
	_locationManager.delegate = self;
	_locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;//kCLLocationAccuracyBest
	_locationManager.distanceFilter = 500;//米
	
#if TARGET_IPHONE_SIMULATOR//[CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied
	// LiXingCheng's home:http://api.map.baidu.com/lbsapi/getpoint/index.html
	_coord.longitude = 121.527799;//东经
	_coord.latitude = 31.216153;//北纬
	
	// default's home
//	_coord.longitude = 0.0;
//	_coord.latitude = 0.0;
    
    _isLocationOk = YES;
    
    // 需要尽量少的调用CLGeocoder，否则可能会导致解析失败。
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(startGeoCoder) withObject:nil afterDelay:1.0];
#else
    //建议只请求⓵和⓶中的一个，如果两个权限都需要，只请求⓶即可
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        [_locationManager requestWhenInUseAuthorization];//⓵只在前台开启定位
        //[_locationManager requestAlwaysAuthorization];//⓶在后台也可定位
    }
    // iOS9新特性：将允许出现这种场景：同一app中多个location manager：一些只能在前台定位，另一些可在后台定位（并可随时禁止其后台定位）。
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        //_locationManager.allowsBackgroundLocationUpdates = YES;
    }
	[_locationManager startUpdatingLocation];
#endif
}

- (void)stop {
	[_locationManager stopUpdatingLocation];
}

- (void)applicationWillResignActive {
	[self stop];
}

- (void)applicationDidBecomeActive {
	_locationFaked = NO;
	[self start];
}

- (void)startGeoCoder {
	if (_geoCoder) {
		[_geoCoder cancelGeocode];
		_geoCoder = nil;
	}
	
    _geoCoder = [[CLGeocoder alloc] init];
    CLLocation *location=[[CLLocation alloc] initWithLatitude:_coord.latitude longitude:_coord.longitude];
    __weak LocationManager *weakSelf = self;
    [_geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        __strong LocationManager *strongSelf = weakSelf;
        if (strongSelf == nil) return;
        
        if ([placemarks count] > 0 && error == nil) {
            CLog(@"CLGeocoder finished...");
            CLog(@"Found %@ placemark(s).", @([placemarks count]));
            CLPlacemark *firstPlacemark = [placemarks objectAtIndex:0];
            
            CLog(@"Longitude = %f", firstPlacemark.location.coordinate.longitude);
            CLog(@"Latitude = %f", firstPlacemark.location.coordinate.latitude);
            
            CLog(@"country:%@",firstPlacemark.country);//中国
            CLog(@"ISOcountryCode:%@",firstPlacemark.ISOcountryCode);//CN
            CLog(@"locality:%@",firstPlacemark.locality);//上海市
            CLog(@"subLocality:%@",firstPlacemark.subLocality);//浦东新区
            CLog(@"postalCode:%@",firstPlacemark.postalCode);//200127
            CLog(@"thoroughfare:%@",firstPlacemark.thoroughfare);//峨山路
            CLog(@"subThoroughfare:%@",firstPlacemark.subThoroughfare);//137号
            CLog(@"administrativeArea:%@",firstPlacemark.administrativeArea);//上海市
            _placemark=nil;
            _placemark = [firstPlacemark copy];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:LocationChanged object:nil];
        }
        else if ([placemarks count] == 0 && error == nil) {
            CLog(@"CLGeocoder Found no placemarks.");
        }
        else if (error != nil) {
            CLog(@"CLGeocoder error:%@", error);
            
            if (!_placemark && _geoCount<3) {
                [self performSelector:@selector(startGeoCoder) withObject:nil afterDelay:1.0];
                _geoCount++;
            }
            else{
                [[NSNotificationCenter defaultCenter] postNotificationName:LocationChanged object:nil];
            }
        }
    }];
}

#pragma mark CLLocationManager delegate
//- (void) locationManager: (CLLocationManager *) manager 
//	 didUpdateToLocation: (CLLocation *) newLocation
//			fromLocation: (CLLocation *) oldLocation{
//	[_locationManager stopUpdatingLocation];
////    [_locationManager performSelector:@selector(startUpdatingLocation) withObject:nil afterDelay:5*60.0f];//60秒
//    
//	_coord.longitude = newLocation.coordinate.longitude;
//	_coord.latitude = newLocation.coordinate.latitude;
//	CLog(@"loction: (%.6f, %.6f)", _coord.longitude, _coord.latitude);
//    _isLocationOk = YES;
//	
//	// 需要尽量少的调用CLGeocoder，否则可能会导致解析失败。
//	[NSObject cancelPreviousPerformRequestsWithTarget:self];
//	[self performSelector:@selector(startGeoCoder) withObject:nil afterDelay:1.0];
//}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    for (CLLocation *location in locations) {
        if ([location.timestamp timeIntervalSinceNow] > - 60
            && location.horizontalAccuracy > 0 && location.horizontalAccuracy < 500) {
            [_locationManager stopUpdatingLocation];
            //[_locationManager performSelector:@selector(startUpdatingLocation) withObject:nil afterDelay:5*60.0f];//60秒
            
            _coord.longitude = location.coordinate.longitude;
            _coord.latitude = location.coordinate.latitude;
            CLog(@"loction: (%.6f, %.6f)", _coord.longitude, _coord.latitude);//http://api.map.baidu.com/lbsapi/getpoint/index.html
            _isLocationOk = YES;
            
            // 需要尽量少的调用CLGeocoder，否则可能会导致解析失败。
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(startGeoCoder) withObject:nil afterDelay:1.0];
            return;
        }
    }
}

- (void) locationManager: (CLLocationManager *) manager didFailWithError: (NSError *) error {
    CLog(@"locationManager error : %@",error);
	if ([error code] == kCLErrorDenied) {
        _coord.longitude = 0.0;
        _coord.latitude = 0.0;
        
        if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied) {
            float fSystemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
//            [[TKAlertCenter defaultCenter] postAlertWithMessage:[NSString stringWithFormat:fSystemVersion >= 6.0f?@"%@需要打开定位服务，请在[设置->隐私->定位服务]里开启":@"%@需要打开定位服务，请在[设置->定位服务]里开启",kProductName]];
            
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:fSystemVersion >= 6.0f?@"%@需要打开定位服务，请在[设置->隐私->定位服务]里开启":@"%@需要打开定位服务，请在[设置->定位服务]里开启",kProductName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
            [av show];
        }
	}
	
	_isLocationOk = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:LocationChanged object:nil];
}

-(double)latitude{
	return _coord.latitude;
}

-(double)longitude{
	return _coord.longitude;	
}
- (CLPlacemark *)placemark{
    return _placemark;
}

-(NSString*)locationString{
    if (_placemark && [_placemark isKindOfClass:[CLPlacemark class]]) {
        return [NSString stringWithFormat:@"%@%@%@%@"
                ,[_placemark.locality isKindOfClass:[NSString class]] ? (_placemark.locality?_placemark.locality:_placemark.administrativeArea) : _placemark.administrativeArea
                ,[_placemark.subLocality isKindOfClass:[NSString class]] ? _placemark.subLocality : @""
                ,[_placemark.thoroughfare isKindOfClass:[NSString class]] ? _placemark.thoroughfare : @""
                ,[_placemark.subThoroughfare isKindOfClass:[NSString class]] ? _placemark.subThoroughfare : @""];
    }
    return [NSString stringWithFormat:@"%.6f %.6f",[self latitude],[self longitude]];
}

- (void)setChoosedCoord:(CLLocationCoordinate2D)c {
    [self stop];
    _coord = c;
    _isLocationOk = YES;
    _locationFaked = YES;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _placemark = nil;
    [self startGeoCoder];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == alertView.cancelButtonIndex) {//取消
    }
    else{
        if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: UIApplicationOpenSettingsURLString]];//如果点击打开的话，需要记录当前的状态，从设置回到应用的时候会用到
        }
        else{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
        }
    }
}

@end
