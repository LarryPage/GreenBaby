//
//  MapViewController.h
//  CardBump
//
//  Created by 香成 李 on 11-9-17.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MKMapView.h>
#import <MapKit/MapKit.h>

// notification
#define AddressChanged		@"AddressChanged"

@interface MapViewController : BaseViewController{
}
@property (nonatomic, strong) MKUserLocation *location;
@property (nonatomic, assign) BOOL showSelfLocation;
@property (nonatomic, assign) BOOL enableEditLocation;

- (void)startReverseGeocoder;//经纬度->地址
- (void)startForwardGeocoder;//地址->经纬度

-(NSString*)adressString;

@end
