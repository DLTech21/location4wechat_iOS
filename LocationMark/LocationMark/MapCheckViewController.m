//
//  MapCheckViewController.m
//  happychat
//
//  Created by Donal Tong on 16/1/7.
//  Copyright © 2016年 dl. All rights reserved.
//

#import "MapCheckViewController.h"
#import "UIView+SDAutoLayout.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#define UIColorFromRGB(rgbValue,al) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:al]
#define screen_width [UIScreen mainScreen].bounds.size.width
#define screen_height [UIScreen mainScreen].bounds.size.height
#define WEAKSELF typeof(self) __weak weakSelf = self;
@interface MapCheckViewController () <BMKMapViewDelegate, BMKLocationServiceDelegate>
{
    BMKMapView *_mapView;
    UIView *bottomView;
    UILabel *tapLabel;
    UILabel *locationLabel;
    UIButton *navButton;
    BMKLocationService *_locService;
}
@end

@implementation MapCheckViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_mapView viewWillAppear];
    _mapView.delegate=self;
    _locService.delegate = self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; //不用时，置nil
    _locService.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initMap];
    [self initLocationService];
}

-(void)initLocationService
{
    if (_locService==nil) {
        
        _locService = [[BMKLocationService alloc]init];
        
        [_locService setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    
    _locService.delegate = self;
    
    
    
}

-(void)initMap
{
    [self.view setBackgroundColor:UIColorFromRGB(0xffffff, 1.0)];
    if (_mapView==nil) {
        
        _mapView=[[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
        
        [_mapView setMapType:BMKMapTypeStandard];// 地图类型 ->卫星／标准、
        
        _mapView.zoomLevel=19;
        
        _mapView.showsUserLocation = YES;
    }
    
    _mapView.delegate=self;
    
    _mapView.centerCoordinate = self._pt;
    [self.view addSubview:_mapView];
    
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    annotation.coordinate = self._pt;
    annotation.title = self.address;
    [_mapView addAnnotation:annotation];
    _mapView.sd_layout.bottomSpaceToView(self.view, 80);
    bottomView = [UIView new];
    [self.view addSubview:bottomView];
    bottomView.sd_layout
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .topSpaceToView(_mapView, 0)
    .bottomSpaceToView(self.view, 0);
    
    tapLabel = [UILabel new];
    [bottomView addSubview:tapLabel];
    tapLabel.sd_layout
    .leftSpaceToView(bottomView, 10)
    .topSpaceToView(bottomView, 10)
    .rightSpaceToView(bottomView, 0)
    .autoHeightRatio(0);
    tapLabel.text = @"[位置]";
    tapLabel.textColor = UIColorFromRGB(0x000000, 1.0);
    tapLabel.font = [UIFont systemFontOfSize:21];
    
    locationLabel = [UILabel new];
    [bottomView addSubview:locationLabel];
    locationLabel.sd_layout
    .leftSpaceToView(bottomView, 10)
    .rightSpaceToView(bottomView, 100)
    .topSpaceToView(tapLabel, 10)
    .autoHeightRatio(0);
    locationLabel.text = _address;
    locationLabel.textColor = UIColorFromRGB(0xdddddd, 1.0);
    locationLabel.font = [UIFont systemFontOfSize:16];
    
    navButton = [UIButton new];
    [bottomView addSubview:navButton];
    [navButton setImage:[UIImage imageNamed:@"btn_nav"] forState:UIControlStateNormal];
    navButton.sd_layout
    .widthIs(48)
    .heightIs(48)
    .centerYEqualToView(bottomView)
    .rightSpaceToView(bottomView, 20)
    ;
    [navButton addTarget:self action:@selector(startNav) forControlEvents:UIControlEventTouchUpInside];
}

-(void)startNav
{
    [_locService startUserLocationService];
}

- (void)openNativeNavi:(CLLocationCoordinate2D)sp
{
    BMKNaviPara* para = [[BMKNaviPara alloc]init];
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    start.pt = sp;
    start.name = @"我的位置";
    para.startPoint = start;
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    end.pt = self._pt;
    end.name = _address;
    para.endPoint = end;
    para.appScheme = @"baidumapsdk://mapsdk.baidu.com";
    [BMKNavigation openBaiduMapNavigation:para];
}

#pragma mark BMKLocationServiceDelegate
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [self openNativeNavi:userLocation.location.coordinate];
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
