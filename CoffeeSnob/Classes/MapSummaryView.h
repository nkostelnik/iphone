//
//  CoffeeShopView.h
//  CoffeeSnob
//
//  Created by Mark H on 28/02/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoffeeShopMapAnnotation.h"


@interface MapSummaryView : UIView {
	IBOutlet UILabel* name;
	IBOutlet UILabel* description;
	IBOutlet UIImageView* image;	
}

@property (nonatomic, retain) IBOutlet UILabel* name;
@property (nonatomic, retain) IBOutlet UILabel* description;
@property (nonatomic, retain) IBOutlet UIImageView* image;

- (void) setAnnotation:(CoffeeShopMapAnnotation *)annotation;

@end
