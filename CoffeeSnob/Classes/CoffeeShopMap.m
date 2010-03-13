//
//  CoffeeMap.m
//  CoffeeSnob
//
//  Created by Mark H on 22/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CoffeeShopMap.h"

#import <MapKit/MapKit.h>

@implementation CoffeeShopMap

NSInteger const FIVE_MINUTES = 300;
NSInteger const ONE_HUNDRED_METRES = 100;

- (id)init {
	[super init];
	coffeeShops = [[CoffeeShopsList alloc]init];
	locationManager = [[CLLocationManager alloc] init];
	lock = [[NSLock alloc]init];
	return self;
}

- (void)startUpdatingLocation {
	locationFound = false;
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	[locationManager startUpdatingLocation];	
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	[lock lock];
	NSTimeInterval ageOfLocationUpdate = [newLocation.timestamp timeIntervalSinceNow];
	ageOfLocationUpdate = fabs(ageOfLocationUpdate);
	if (!locationFound && ageOfLocationUpdate < FIVE_MINUTES && newLocation.horizontalAccuracy < ONE_HUNDRED_METRES) {
		locationFound = true;
		[locationManager stopUpdatingLocation];
		mapView.showsUserLocation = YES;
		[mapView.userLocation addObserver:self forKeyPath:@"location" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
	}
	[lock unlock];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[mapView.userLocation removeObserver:self forKeyPath:@"location"];
	if ([viewController respondsToSelector:@selector(locationUpdated)]) {
		[viewController performSelector:@selector(locationUpdated)];
	}	
}

- (void) showAnnotationForShop:(CoffeeShop *)coffeeShop  {	
	CoffeeShopMapAnnotation* coffeeShopAnnotation = [coffeeShop getMapAnnotation];
	for (NSObject<MKAnnotation> *annotation in mapView.annotations) {
		if (![[annotation title] compare:[coffeeShopAnnotation title]]) {
			[mapView selectAnnotation:annotation animated:NO];
			return;
		}
	}
	[mapView addAnnotation:coffeeShopAnnotation];
}

- (void) zoomMapToUserAndShop:(CoffeeShop *)coffeeShop  {
	double longitudeDifference = (coffeeShop.location.coordinate.longitude - locationManager.location.coordinate.longitude);
	double latitudeDifference = (coffeeShop.location.coordinate.latitude - locationManager.location.coordinate.latitude);
	double centerMapLongitude = locationManager.location.coordinate.longitude + (longitudeDifference / 2);
	double centerMapLatitude = locationManager.location.coordinate.latitude + (latitudeDifference / 2);

	longitudeDifference = longitudeDifference * 1.4;
	latitudeDifference = latitudeDifference * 1.5;
	
	MKCoordinateRegion region;
	region.center = [[[CLLocation alloc]initWithLatitude:centerMapLatitude longitude:centerMapLongitude] coordinate];
	region.span.latitudeDelta = (latitudeDifference > 0) ? latitudeDifference : -latitudeDifference;
	region.span.longitudeDelta = (longitudeDifference > 0) ? longitudeDifference : -longitudeDifference;
	[mapView setRegion:region animated:YES];
}

- (void) showNextCoffeeShopToUser {
	CoffeeShop* coffeeShop = [coffeeShops getNextCoffeeShop];
	[self selectShop:coffeeShop];
}

- (void)shopsLoaded:(NSMutableArray *)shops {
	[coffeeShops addCoffeeShops:shops userLocation:locationManager.location];
	[self showNextCoffeeShopToUser];
}

- (void)selectShop:(CoffeeShop*)coffeeShop {	
	[self zoomMapToUserAndShop:coffeeShop];
	[self showAnnotationForShop:coffeeShop];	
}

-(CLLocation *)getSelectedCoffeeShopLocation{	
	CoffeeShopMapAnnotation* coffeeShopAnnotation = [mapView.selectedAnnotations objectAtIndex:0];
	return [[CLLocation alloc]initWithLatitude:coffeeShopAnnotation.coordinate.latitude longitude:coffeeShopAnnotation.coordinate.longitude];
}

- (void)showDirectionsToSelectedCoffeeShop {
	CLLocation* coffeeShoplocation = [self getSelectedCoffeeShopLocation];
	NSString *startAddress = [NSString stringWithFormat: @"%f,%f", mapView.userLocation.coordinate.latitude, mapView.userLocation.coordinate.longitude];
    NSString *destination = [NSString stringWithFormat: @"%f,%f", coffeeShoplocation.coordinate.latitude, coffeeShoplocation.coordinate.longitude];
	NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%@&daddr=%@", startAddress, destination]; 
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end
