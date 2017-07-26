//
//  LocationManager.h
//  CardBump
//
//  Created by 香成 李 on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

// notification
#define LocationChanged		@"LocationChanged"

@interface LocationManager : NSObject{
}

@property (nonatomic, readonly) BOOL isLocationOk;//是否定位成功
@property (nonatomic, readonly) BOOL locationFaked;//是否伪造的位置,自己定义的位置
@property (nonatomic, readonly) CLLocationCoordinate2D coord;

SINGLETON_DEF(LocationManager)

- (void)start;
- (void)stop;
- (double)latitude;
- (double)longitude;
- (CLPlacemark *)placemark;
- (NSString*)locationString;
- (void)setChoosedCoord:(CLLocationCoordinate2D)c;


@end
