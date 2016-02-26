//
//  ViewController.h
//  LocationMark
//
//  Created by Donal Tong on 16/2/26.
//  Copyright © 2016年 Donal. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LocationViewControllerDelegate <NSObject>

-(void)sendLocationLatitude:(double)latitude longitude:(double)longitude andAddress:(NSString *)address;

@end

@interface ViewController : UIViewController

@property (nonatomic, assign) id<LocationViewControllerDelegate> delegate;
@end

