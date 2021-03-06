//
//  CoffeeShopView.m
//  CoffeeSnob
//
//  Created by Mark H on 28/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MapSummaryView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MapSummaryView

@synthesize name;
@synthesize description;
@synthesize image;

- (id)initWithCoder:(NSCoder *)aDecoder {
	[super initWithCoder:aDecoder];
	
	self.layer.cornerRadius = 11;
	return self;
}

- (void) setAnnotation:(CoffeeShopMapAnnotation *)annotation  {
	self.hidden = (name.text == annotation.coffeeShopName);
	name.text = name.text == annotation.coffeeShopName ? @"" : annotation.coffeeShopName;
	description.text = annotation.coffeeShopDescription;
	image.image = [annotation getCoffeeShopImage];
}

- (void)dealloc {
    [super dealloc];
}

@end
