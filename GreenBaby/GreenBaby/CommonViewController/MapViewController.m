//
//  MapViewController.m
//  CardBump
//
//  Created by 香成 李 on 11-9-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController ()<MKMapViewDelegate>{
    MKPointAnnotation *_pointAnnotation;
    MKPinAnnotationView *_pointAnnotationView;
    
    //CLGeocoder可正反解析，ios5以上
    CLGeocoder *_geoCoder;
    CLPlacemark *_placemark;
    NSInteger _geoCount;//尝试解析3次
}
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UIView *noticeView;
@end

@implementation MapViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //_geoCoder = [[CLGeocoder alloc] init];
        _placemark = nil;
        _geoCount=0;
    }
    return self;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (_geoCoder) {
        [_geoCoder cancelGeocode];
        _geoCoder = nil;
    }
    if (_mapView) {
        _mapView.delegate = nil;
        _mapView = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	self.noticeView.hidden = YES;
}

- (void)fadeNoticeView {
	[UIView beginAnimations:@"hideNoticeView" context:nil];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	self.noticeView.alpha = 0.0;
	[UIView commitAnimations];
}

- (void)recenterMap {
    //NSArray *coordinates = [self.mapView valueForKeyPath:@"annotations.coordinate"];
    CLLocationCoordinate2D my_coordinate={[[LocationManager sharedInstance] latitude],[[LocationManager sharedInstance] longitude]};
    NSValue *value1=[NSValue valueWithBytes:&my_coordinate objCType:@encode(CLLocationCoordinate2D)];
    CLLocationCoordinate2D custom_coordinate=self.location.coordinate;
    NSValue *value2=[NSValue valueWithBytes:&custom_coordinate objCType:@encode(CLLocationCoordinate2D)];
    NSArray *coordinates=[NSArray arrayWithObjects:value1,value2, nil];
    CLLocationCoordinate2D maxCoord = {-90.0f, -180.0f};
    CLLocationCoordinate2D minCoord = {90.0f, 180.0f};
    for(NSValue *value in coordinates) {
        CLLocationCoordinate2D coord = {0.0f, 0.0f};
        [value getValue:&coord];
        if(coord.longitude > maxCoord.longitude) {
            maxCoord.longitude = coord.longitude;
        }
        if(coord.latitude > maxCoord.latitude) {
            maxCoord.latitude = coord.latitude;
        }
        if(coord.longitude < minCoord.longitude) {
            minCoord.longitude = coord.longitude;
        }
        if(coord.latitude < minCoord.latitude) {
            minCoord.latitude = coord.latitude;
        }
    }
    MKCoordinateRegion region = {{0.0f, 0.0f}, {0.0f, 0.0f}};
    region.center.longitude = (minCoord.longitude + maxCoord.longitude) / 2.0;
    region.center.latitude = (minCoord.latitude + maxCoord.latitude) / 2.0;
    region.span.longitudeDelta = maxCoord.longitude - minCoord.longitude;
    region.span.latitudeDelta = maxCoord.latitude - minCoord.latitude;
    [self.mapView setRegion:region animated:YES];
}

- (void)closeViewController{
    if (self.enableEditLocation) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AddressChanged object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[self adressString], @"address",nil]];
    }
    
    if (_geoCoder) {
        [_geoCoder cancelGeocode];
        _geoCoder = nil;
    }
    if (_mapView) {
        _mapView.delegate = nil;
        _mapView = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	self.title = @"地理位置";
	
    [self.mapView setShowsUserLocation:self.showSelfLocation];
	
	if (self.enableEditLocation) {
		self.mapView.showsUserLocation = YES;
		UILongPressGestureRecognizer *lpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
		lpress.minimumPressDuration = 0.5;//按0.5秒响应longPress方法
		lpress.allowableMovement = 10.0;
		[self.mapView addGestureRecognizer:lpress];//mapView是MKMapView的实例
		[self performSelector:@selector(fadeNoticeView) withObject:nil afterDelay:3];
	} else {
		_noticeView.hidden = YES;
	}
    
    if (_pointAnnotation) {
        [self.mapView removeAnnotation:_pointAnnotation];
        _pointAnnotation = nil;
    }
    _pointAnnotation = [[MKPointAnnotation alloc] init];
    [_pointAnnotation setCoordinate:self.location.coordinate];
    _pointAnnotation.title = self.location.title;//@"已放置的大头针";
    _pointAnnotation.subtitle = self.location.subtitle;
    [self.mapView addAnnotation:_pointAnnotation];
    if (self.enableEditLocation) {
        //[self.mapView showAnnotations:@[_pointAnnotation] animated:YES];
        [self.mapView selectAnnotation:_pointAnnotation animated:YES];
    }
    //MKAnnotation display all pin title without clicking
    NSMutableArray *annotationArray =[NSMutableArray arrayWithObject:_pointAnnotation];
    [self.mapView setSelectedAnnotations:annotationArray];
    
    const CLLocationDistance w = 5000;
    self.mapView.region = MKCoordinateRegionMakeWithDistance(self.location.coordinate, w * 367.0 / 320.0, w);
    //[self recenterMap];
    
    // 需要尽量少的调用CLGeocoder，否则可能会导致解析失败。
    //[NSObject cancelPreviousPerformRequestsWithTarget:self];//避免fadeNoticeView
    [self performSelector:@selector(startForwardGeocoder) withObject:nil afterDelay:1.0];
}

- (void)longPress:(UIGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        return;
    }
    //坐标转换
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    if (_pointAnnotation) {
        [self.mapView removeAnnotation:_pointAnnotation];
		_pointAnnotation = nil;
    }
    _pointAnnotation = [[MKPointAnnotation alloc] init];
    _pointAnnotation.coordinate = touchMapCoordinate;
	[self.location setCoordinate:touchMapCoordinate];
	[self.mapView addAnnotation:_pointAnnotation];
	[self.mapView selectAnnotation:_pointAnnotation animated:YES];
}

#pragma mark MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation {
	if ([annotation isKindOfClass:[MKUserLocation class]] && annotation==map.userLocation)
    {
        return nil;
    }
    
    ((MKPointAnnotation *)annotation).title = self.location.title;//@"已放置的大头针";
	((MKPointAnnotation *)annotation).subtitle = self.location.subtitle;
    //MKAnnotationView *pointAnnotationView=[map dequeueReusableAnnotationViewWithIdentifier:@"IDENT"];
    if (!_pointAnnotationView) {
        _pointAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        _pointAnnotationView.pinColor = MKPinAnnotationColorRed;//设置大头针的颜色
        _pointAnnotationView.animatesDrop = YES;
        _pointAnnotationView.canShowCallout = YES;
        _pointAnnotationView.draggable = self.enableEditLocation;//可以拖动
        //_pointAnnotationView.leftCalloutAccessoryView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 46, 46)];
        _pointAnnotationView.rightCalloutAccessoryView = nil;//[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }else{
        _pointAnnotationView.annotation = self.location;
    }
    
    return _pointAnnotationView;
}

//- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
//    [self performSegueWithIdentifier:@"button click" sender:view];
//}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	if (newState == MKAnnotationViewDragStateEnding) {
		self.location = view.annotation;
        
        _placemark = nil;
        _geoCount=0;
        // 需要尽量少的调用CLGeocoder，否则可能会导致解析失败。
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(startReverseGeocoder) withObject:nil afterDelay:1.0];
	}
}

#pragma mark CLGeocoder

-(NSString*)adressString{
    if (_placemark && [_placemark isKindOfClass:[CLPlacemark class]]) {
        return [NSString stringWithFormat:@"%@ %@, %@, %@",
                _placemark.subThoroughfare?_placemark.subThoroughfare:@"",
                _placemark.thoroughfare?_placemark.thoroughfare:@"",
                _placemark.locality?_placemark.locality:@"",
                _placemark.country?_placemark.country:@""];
    }
    else{
        return [NSString stringWithFormat:@"%.6f %.6f",self.location.coordinate.latitude,self.location.coordinate.longitude];
    }
}

//经纬度->地址
- (void)startReverseGeocoder {
    if (_geoCoder) {
        [_geoCoder cancelGeocode];
        _geoCoder = nil;
    }
    
    _geoCoder = [[CLGeocoder alloc] init];
    CLLocation *location=[[CLLocation alloc] initWithLatitude:self.location.coordinate.latitude longitude:self.location.coordinate.longitude];
    __weak MapViewController *weakSelf = self;
    [_geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        __strong MapViewController *strongSelf = weakSelf;
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
            _placemark = firstPlacemark;
            
            self.location.subtitle=[self adressString];
        }
        else if ([placemarks count] == 0 && error == nil) {
            CLog(@"CLGeocoder Found no placemarks.");
        }
        else if (error != nil) {
            CLog(@"CLGeocoder error:%@", error);
            
            if (!_placemark && _geoCount<3) {
                [self performSelector:@selector(startReverseGeocoder) withObject:nil afterDelay:1.0];
                _geoCount++;
            }
            else{
                _placemark=nil;
            }
        }
    }];
}

//地址->经纬度
- (void)startForwardGeocoder {
    if (_geoCoder) {
        [_geoCoder cancelGeocode];
        _geoCoder = nil;
    }
    
    _geoCoder = [[CLGeocoder alloc] init];
    __weak MapViewController *weakSelf = self;
    [_geoCoder geocodeAddressString:self.location.subtitle completionHandler:^(NSArray *placemarks, NSError *error) {
        __strong MapViewController *strongSelf = weakSelf;
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
            _placemark = firstPlacemark;
            
            CLLocationCoordinate2D coord;
            coord.latitude = firstPlacemark.location.coordinate.latitude;
            coord.longitude = firstPlacemark.location.coordinate.longitude;
            
            if (_pointAnnotation) {
                [self.mapView removeAnnotation:_pointAnnotation];
                _pointAnnotation = nil;
            }
            _pointAnnotation = [[MKPointAnnotation alloc] init];
            _pointAnnotation.coordinate = coord;
            [self.location setCoordinate:coord];
            _pointAnnotation.title = self.location.title;//@"已放置的大头针";
            _pointAnnotation.subtitle = self.location.subtitle;
            [self.mapView addAnnotation:_pointAnnotation];
            if (self.enableEditLocation) {
                [self.mapView selectAnnotation:_pointAnnotation animated:YES];
            }
            //MKAnnotation display all pin title without clicking
            NSMutableArray *annotationArray =[NSMutableArray arrayWithObject:_pointAnnotation];
            [self.mapView setSelectedAnnotations:annotationArray];
            
            const CLLocationDistance w = 5000;
            self.mapView.region = MKCoordinateRegionMakeWithDistance(self.location.coordinate, w * 367.0 / 320.0, w);
            //[self recenterMap];
        }
        else if ([placemarks count] == 0 && error == nil) {
            CLog(@"CLGeocoder Found no placemarks.");
        }
        else if (error != nil) {
            CLog(@"CLGeocoder error:%@", error);
            
            if (!_placemark && _geoCount<3) {
                [self performSelector:@selector(startForwardGeocoder) withObject:nil afterDelay:1.0];
                _geoCount++;
            }
            else{
                _placemark=nil;
            }
        }
    }];
}

@end
